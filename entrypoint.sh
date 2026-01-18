#!/bin/ash - 
# Copyright 2024, 2025, 2026 Michael Konrad 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o nounset                              # Treat unset variables as an error

PHX_HOME=/opt/phoenix
# set ecto install to no by default
ECTO="${ECTO:-n}"
# docker secrets - db secret file
DB_SECRET_FILE=/run/secrets/postgres_password
DB_PWD="${DB_PWD:-}"
APP_NAME="${APP_NAME:-}"

get_db_pwd() {
	# DB_PWD variable is optional for testing
	if [[ -z $DB_PWD ]]; then
		# read the database password from a docker's secret file
		if [ -f "$DB_SECRET_FILE" ]; then
			DB_PWD=$(head -n 1 $DB_SECRET_FILE)
		else
			printf "Database secret is not set, aborting install.\n"
			exit 1
		fi
	fi
}


git_cleanup() {
	# remove the git repository if it exists
	if [[ -d $PHX_HOME/$APP_NAME/.git ]]; then
		printf "Removing git repository...\n"
		rm -rf $PHX_HOME/$APP_NAME/.git
	fi

	if [[ -f $PHX_HOME/$APP_NAME/.gitignore ]]; then
		printf "Removing gitignore file...\n"
		rm -f $PHX_HOME/$APP_NAME/.gitignore
	fi
}


phx_install() {
	# ensure APP_NAME has been set 
	if [ -n $APP_NAME ]; then
		# program directory /opt/phoenix
		if [[ ! -d $PHX_HOME/$APP_NAME/config ]]; then
			printf "Running mix phx.new...\n"
			if [[ $ECTO == 'y' ]]; then
				yes Y | mix phx.new --install $PHX_HOME/$APP_NAME --binary-id
			else
				yes Y | mix phx.new --install --no-ecto $PHX_HOME/$APP_NAME --binary-id
			fi
			
			if [ $? -lt 1 ]; then 
				phx_config
			fi
		fi
	else
		printf "APP_NAME has not been set, exiting."
		exit 1
	fi
}


phx_config() {
	# program directory /opt/phoenix
	if [[ -d $PHX_HOME/$APP_NAME/config ]]; then
		# Configure dev.exs for docker
		printf "Updating dev.exs...\n"
		update_file="$PHX_HOME/$APP_NAME/config/dev.exs"
		if [[ $ECTO == 'y' ]]; then
			get_db_pwd		
			sed -i '' -e "s|\(password: \).*|\1"\"$DB_PWD\","|" \
			-e 's|"localhost"|"db"|' \
			-e 's|127, 0, 0, 1|0, 0, 0, 0|' $update_file >/dev/null 2>&1

			# create the database
			cd $PHX_HOME/$APP_NAME
			mix ecto.create
		else
			sed -i '' -e 's|127, 0, 0, 1|0, 0, 0, 0|' $update_file >/dev/null 2>&1
		fi

		# Configure test.exs for docker
		printf "Updating test.exs...\n"
		update_file="$PHX_HOME/$APP_NAME/config/test.exs"
		if [[ $ECTO == 'y' ]]; then
			get_db_pwd		
			sed -i '' -e "s|\(password: \).*|\1"\"$DB_PWD\","|" \
			-e 's|"localhost"|"db"|' \
			-e 's|127, 0, 0, 1|0, 0, 0, 0|' $update_file >/dev/null 2>&1
		else	
			sed -i '' -e 's|127, 0, 0, 1|0, 0, 0, 0|' $update_file >/dev/null 2>&1
		fi
	fi
}


twai_install() {
	if [[ ! -f $PHX_HOME/$APP_NAME/deps/tidewave/lib/tidewave.ex ]]; then
		cd $PHX_HOME/$APP_NAME
		# Install igniter and tidewave.ai
		yes Y | mix archive.install hex igniter_new
		yes Y | mix igniter.install tidewave

		if [ $? -lt 1 ]; then
			twai_config
		fi
	fi
}


twai_config() {
	# Configure tidewave.ai for docker
	printf "Updating endpoint.ex to allow remote access to tidewave.ai...\n"
	app_web="${APP_NAME}_web"
	update_file="$PHX_HOME/$APP_NAME/lib/$app_web/endpoint.ex"
	# endpoint.ex 
	#  plug Plug.MethodOverride
	#  plug Tidewave, :allow_remote_access
	if [[ -f $update_file ]]; then
		sed -i '' -e 's|\(plug Tidewave\)|\1, allow_remote_access: true|' $update_file >/dev/null 2>&1
	fi
}


main() {
	phx_install 
	twai_install

	exec "$@"
}

main "$@"