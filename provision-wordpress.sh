#!/bin/bash
set -e
set -o pipefail
set -x

echo -e "${GREEN} Removing default plugins...${NC}"
docker exec -t edx.devstack.wordpress  bash -c 'cd wp-content/plugins/ && rm -rf akismet && rm -rf hello.php'

echo -e "${GREEN} Install required Plugins...${NC}"
docker exec -t edx.devstack.wordpress  bash -c '
cd wp-content/plugins/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar plugin install advanced-custom-fields --activate --allow-root &&
php wp-cli.phar plugin install edunext-openedx-integrator --activate --allow-root &&
php wp-cli.phar plugin install elementor --activate --allow-root &&
php wp-cli.phar plugin install classic-editor --activate --allow-root &&
php wp-cli.phar plugin install contact-form-7 --activate --allow-root &&
php wp-cli.phar plugin install mailchimp-for-wp --activate --allow-root &&
php wp-cli.phar plugin install all-in-one-wp-migration --allow-root &&
php wp-cli.phar plugin activate edly-wp-plugin --allow-root &&
rm -rf wp-cli.phar &&
chown www-data:www-data -R advanced-custom-fields &&
chown www-data:www-data -R edunext-openedx-integrator &&
chown www-data:www-data -R advanced-custom-fields &&
chown www-data:www-data -R elementor &&
chown www-data:www-data -R classic-editor &&
chown www-data:www-data -R contact-form-7 &&
chown www-data:www-data -R all-in-one-wp-migration'

echo -e "${GREEN} Enable edly-wp-theme...${NC}"
docker exec -t edx.devstack.wordpress  bash -c '
cd wp-content/themes/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar theme get st-lutherx --allow-root &&
php wp-cli.phar theme activate st-lutherx --allow-root &&
rm -rf wp-cli.phar
'
echo -e "${GREEN} Update Wordpress Configurations...${NC}"
docker exec -t edx.devstack.wordpress  bash -c "
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&
php wp-cli.phar config set 'DISCOVERY_API_URL' 'http://edx.devstack.discovery:18381/api/v1' --allow-root &&
php wp-cli.phar config set 'LMS_BASE_URL' 'http://edx.devstack.lms:18000' --allow-root &&
php wp-cli.phar config set 'ENROLLMENT_API_URL' 'http://edx.devstack.lms:18000/api/enrollment/v1' --allow-root &&
php wp-cli.phar config set 'ENROLLMENT_STATUS_API_URL' 'http://edx.devstack.lms:18000/api/enrollment/v1/enrollment' --allow-root &&
php wp-cli.phar config set 'COURSE_DASHBOARD_URL' 'http://edx.devstack.lms:18000/dashboard' --allow-root &&
php wp-cli.phar config set 'COURSE_REGISTER_URL' 'http://edx.devstack.lms:18000/register' --allow-root &&
php wp-cli.phar config set 'COURSE_DETAIL_URL' 'http://edx.devstack.lms:18000/courses' --allow-root &&
php wp-cli.phar config set 'DISCOVERY_CLIENT_ID' 'discovery-key' --allow-root &&
php wp-cli.phar config set 'DISCOVERY_CLIENT_SECRET' 'discovery-secret' --allow-root &&
php wp-cli.phar config set 'IS_LOGGED_IN_COOKIE' 'edxloggedin' --allow-root &&
php wp-cli.phar config set 'USER_INFO_COOKIE' 'edx-user-info' --allow-root &&
php wp-cli.phar config set 'WP_ENVIRONMENT_TYPE' 'local' --allow-root &&
rm -rf wp-cli.phar
"

echo -e "${GREEN} Requirements ...${NC}"
cd .. && cd edly-wp-plugin && make test-requirements && cd ../devstack
cd .. && cd edly-wp-theme/st-lutherx && make test-requirements && make requirements && make compile-sass && make compile-js && cd ../../devstack
cd .. && cd edly-wp-theme/st-normanx && make test-requirements && make requirements && make compile-sass && make compile-js && cd ../../devstack
