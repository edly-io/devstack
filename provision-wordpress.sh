#!/bin/bash
set -e
set -o pipefail
set -x

echo -e "${GREEN} Removing default plugins...${NC}"
docker exec -t edx.${COMPOSE_PROJECT_NAME:-devstack}.wordpress  bash -c 'cd wp-content/plugins/ && rm -rf akismet && rm -rf hello.php'

echo -e "${GREEN} Enable multisite...${NC}"
docker exec -t edx.${COMPOSE_PROJECT_NAME:-devstack}.wordpress  bash -c '
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar core multisite-install --title="Edly" --url="wordpress.edx.devstack.lms" --admin_user="admin" --admin_password="admin"  --admin_email="edx@example.com" --subdomains --allow-root &&
rm -rf wp-cli.phar
'

echo -e "${GREEN} Install required Plugins...${NC}"
docker exec -t edx.${COMPOSE_PROJECT_NAME:-devstack}.wordpress  bash -c '
cd wp-content/plugins/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar plugin install advanced-custom-fields --activate --allow-root &&
php wp-cli.phar plugin install elementor --activate --allow-root &&
php wp-cli.phar plugin install classic-editor --activate --allow-root &&
php wp-cli.phar plugin install contact-form-7 --activate --allow-root &&
php wp-cli.phar plugin install mailchimp-for-wp --activate --allow-root &&
php wp-cli.phar plugin activate edly-wp-plugin --allow-root &&
rm -rf wp-cli.phar &&
chown www-data:www-data -R advanced-custom-fields &&
chown www-data:www-data -R elementor &&
chown www-data:www-data -R classic-editor &&
chown www-data:www-data -R contact-form-7'

echo -e "${GREEN} Enable edly-wp-theme...${NC}"
docker exec -t edx.${COMPOSE_PROJECT_NAME:-devstack}.wordpress  bash -c '
cd wp-content/themes/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar theme get st-lutherx --allow-root &&
php wp-cli.phar theme activate st-lutherx --allow-root &&
rm -rf wp-cli.phar
'
echo -e "${GREEN} Update Wordpress Configurations...${NC}"
docker exec -t edx.${COMPOSE_PROJECT_NAME:-devstack}.wordpress  bash -c "
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar config set 'DISCOVERY_CLIENT_ID' 'discovery-key' --allow-root &&
php wp-cli.phar config set 'DISCOVERY_CLIENT_SECRET' 'discovery-secret' --allow-root &&
php wp-cli.phar config set 'IS_LOGGED_IN_COOKIE' 'edxloggedin' --allow-root &&
php wp-cli.phar config set 'USER_INFO_COOKIE' 'edx-user-info' --allow-root &&
php wp-cli.phar config set 'WP_ENVIRONMENT_TYPE' 'local' --allow-root &&
php wp-cli.phar config set 'EDLY_USER_INFO_COOKIE_NAME' 'edly-user-info' --allow-root &&
php wp-cli.phar config set 'EDLY_COOKIE_SECRET_KEY' 'EDLY-COOKIE-SECRET-KEY' --allow-root &&
php wp-cli.phar config set 'EDLY_JWT_ALGORITHM' 'HS256' --allow-root &&
php wp-cli.phar config set 'EDX_API_KEY' 'PUT_YOUR_API_KEY_HERE' --allow-root &&
rm -rf wp-cli.phar
"

echo -e "${GREEN} Requirements ...${NC}"
cd .. && cd edly-wp-plugin && make test-requirements && cd ../devstack
cd .. && cd edly-wp-theme/st-lutherx && make test-requirements && make requirements && make compile-sass && make compile-js && cd ../../devstack
cd .. && cd edly-wp-theme/st-normanx && make test-requirements && make requirements && make compile-sass && make compile-js && cd ../../devstack
