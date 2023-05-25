# Script to run commands for setup edly devstack locally
docker-compose $DOCKER_COMPOSE_FILES exec -T lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform &&  ./manage.py lms setup_edly_multisite_devstack_Juniper_locally'

docker-compose $DOCKER_COMPOSE_FILES exec credentials bash -c 'source /edx/app/credentials/credentials_env && cd /edx/app/credentials/credentials/ && ./manage.py setup_credentials_service'

cp ../edx-platform/users_data.csv ../ecommerce
docker-compose $DOCKER_COMPOSE_FILES exec mysql bash -c "mysql -uroot -e 'CREATE USER \"edly\" IDENTIFIED BY \"edly\"; GRANT ALL PRIVILEGES ON *.* TO \"edly\";'"

docker-compose $DOCKER_COMPOSE_FILES exec ecommerce bash -c 'source /edx/app/ecommerce/ecommerce_env && python /edx/app/ecommerce/ecommerce/manage.py setup_ecommerce_service'
docker-compose $DOCKER_COMPOSE_FILES exec ecommerce bash -c 'source /edx/app/ecommerce/ecommerce_env && python /edx/app/ecommerce/ecommerce/manage.py import_user_ids'

docker-compose $DOCKER_COMPOSE_FILES exec -T discovery bash -c 'source /edx/app/discovery/discovery_env && python /edx/app/discovery/discovery/manage.py setup_course_discovery_service'
