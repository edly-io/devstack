Edly Devstack |Build Status|
================================

Get up and running quickly with Edly services.


Prerequisites
-------------

This project requires `docker-ce`_ **17.06+**.  We recommend Docker Stable, but
Docker Edge should work as well.

**NOTE:** Switching between Docker Stable and Docker Edge will remove all images and
settings.  Don't forget to restore your memory setting and be prepared to
provision.

For macOS users, please use `Docker for Mac`_. Previous Mac-based tools (e.g.
boot2docker) are *not* supported.

`Docker for Windows`_ may work but has not been tested and is *not* supported.


**NOTE:** After installing docker, user must be added to user group ``docker``

.. code:: sh

   sudo usermod -aG docker <USERNAME>

then reboot the system and check if docker is installed correctly by running the command:

.. code:: sh

    docker --version

Linux users should *not* be using the ``overlay`` storage driver.  ``overlay2``
is tested and supported, but requires kernel version 4.0+.  Check which storage
driver your docker-daemon is configured to use:

.. code:: sh

   docker info | grep -i 'storage driver'

You will also need the following installed:

- make
- python pip (optional for MacOS)

Using the Latest Images
-----------------------

New images for our services are published frequently.  Assuming that you've followed the steps in `Getting Started`_
below, run the following sequence of commands if you want to use the most up-to-date versions of the devstack images.

.. code:: sh

    make down
    make pull
    make dev.up

This will stop any running devstack containers, pull the latest images, and then start all of the devstack containers.

Get You SSh Keys Added to Edly
------------------------------

Please get access to edly's organization prior to setting up edly devstack.

Basically we need ssh keys which are enabled to access the edly's private repos.
Since at Edly we individually give permissions to our developers so avoid getting access denied error,
we now mount the default directory of ssh keys on Edly developers system, present at ``$HOME/.ssh:/root/.ssh``

This way a developer can install private edly apps,
e.g. `pip install git+ssh://git@github.com/edly-io/edly-panel-edx-app.git#egg=edly-panel-app` directly from ``LMS Shell``.


Getting Started
---------------

All of the services can be run by following the steps below. For analyticstack, follow `Getting Started on Analytics`.

**NOTE:** Since a Docker-based devstack runs many containers,
you should configure Docker with a sufficient
amount of resources. We find that `configuring Docker for Mac`_ with
a minimum of 2 CPUs and 6GB of memory works well.


1. Make a directory for Edly devstack(preferably in the home directory)

.. code:: sh

    mkdir ~/workspace/edly-setup
    cd ~/workspace/edly-setup

2. Make a ``virutalenv`` for edly and activate it.

**NOTE** Ensure that the installed python3 version is python 3.6.5 as the edly panel edx app doesn't work for later
versions.

.. code:: sh

    virtualenv -p python3 edly_env
    source edly_env/bin/activate
    mkdir edly
    cd edly

3. Clone Edly devstack and checkout ``edly/i`` branch and export ``OPENEDX_RELEASE`` environment variable.
Also, turn off git permission tracking globally.
.. code:: sh

    git clone https://github.com/edly-io/devstack.git
    cd devstack
    git checkout edly/i
    export OPENEDX_RELEASE=ironwood.master
    git config --global core.fileMode false

4. Install the requirements.

.. code:: sh

    make requirements

5. The Docker Compose file mounts a host volume for each service's executing
   code. The host directory defaults to be a sibling of this directory. For
   example, if this repo is cloned to ``~/workspace/devstack``, host volumes
   will be expected in ``~/workspace/course-discovery``,
   ``~/workspace/ecommerce``, etc. These repos can be cloned with the command
   below.

.. code:: sh

    make dev.clone

You may customize where the local repositories are found by setting the ``DEVSTACK_WORKSPACE`` environment variable.

Be sure to share the cloned directories in the Docker -> Preferences... -> File Sharing box.

6. Pull any changes made to the various images on which the devstack depends.

.. code:: sh

    make pull

7. Run the provision command, if you haven't already, to configure the various
   services with superusers (for development without the auth service) and
   tenants (for multi-tenancy).

   **NOTE:** When running the provision command, databases for ecommerce and edxapp
   will be dropped and recreated.
   Also, Be sure that virtual environment is activated and `OPENEDX_RELEASE` environment variable is set.

   The username and password for the superusers are both ``edx``. You can access
   the services directly via Django admin at the ``/admin/`` path, or login via
   single sign-on at ``/login/``.

.. code:: sh

    make dev.provision

9. Go into `edx-platform` directory and check if edly-io remote is added.

.. code:: sh

    cd ../edx-platform
    git remote -v

10. If remote is not added, add it.

.. code:: sh

    git remote add edly git@github.com:edly-io/edx-platform.git
    git remote -v

11. Now that edx-platform edly remote has been added, checkout into develop branch and make a pull.

.. code:: sh

    git checkout develop
    git pull edly develop

12. Go into `ecommerce` directory and check if edly-io remote is added.

.. code:: sh

    cd ../ecommerce
    git remote -v

13. If remote is not added, add it.

.. code:: sh

    git remote add edly git@github.com:edly-io/ecommerce.git
    git remote -v

14. Now that ecommerce edly remote has been added, checkout into develop branch and make a pull.

.. code:: sh

    git checkout develop
    git pull edly develop
    cd ../devstack

15. Start the services. This command will mount the repositories under the DEVSTACK\_WORKSPACE directory.

   **NOTE:** it may take up to 60 seconds for the LMS to start, even after the ``make dev.up`` command outputs ``done``.
   Be sure that virtual environment is activated and `OPENEDX_RELEASE` environment variable is set each time
   this command is run.

.. code:: sh

    make dev.up

Install edly-panel-edx-app
--------------------------

Install the edly edx panel app in ``lms-shell`` by following instructions on https://github.com/edly-io/edly-panel-edx-app.

Setup Edly Open edX theme
-------------------------

1. Go to the edly directory.
2. Clone edly-edx-themes repo in the src directory.

.. code:: sh

    https://github.com/edly-io/edly-edx-themes.git

4. Checkout to develop branch if its not already checked out.

5. Copy St-lutherx and st-normanx folders to ``edx/edx-platform/themes`` directory.

Set up Edly Open edX theme for LMS
**********************************

6. Go to devstack directory and get into lms container.

.. code:: sh

    cd devstack
    make lms-shell


7. Edit the ``/edx/app/edxapp/lms.env.json`` file in the docker container and set the following
variables to the following values.

.. code:: json

    "ENABLE_COMPREHENSIVE_THEMING": true,

    "COMPREHENSIVE_THEME_DIRS": [
        "/edx/app/edxapp/edx-platform/themes",
        "/edx/src/edly-edx-themes"
    ]

8. Update assets in the docker shell from the ``/edx/app/edxapp/edx-platform`` folder using this command.

.. code:: sh

    paver update_assets


9. Exit the docker shell using ``Ctrl+D`` or ``exit`` command.
10. Restart lms container.

.. code:: sh

    make lms-restart

11. Go to http://localhost:18000/admin and login using ``edx`` as username and ``edx`` as password.
12. Go to http://localhost:18000/admin/sites/site/ and add a new site with values domain as ``localhost:18000`` and display name as ``st-lutherx``.
13. Go to http://localhost:18000/admin/theming/sitetheme/ and add a new theme with values site as ``localhost:18000`` and Theme dir name as ``st-lutherx``.

Set up Edly Open edX theme for Studio
*************************************

1. Go to devstack directory and get into studio container.

.. code:: sh

    cd devstack
    make studio-shell


2. Edit the ``/edx/app/edxapp/cms.env.json`` file in the docker container and set the following
variables to the following values.

.. code:: json

    "ENABLE_COMPREHENSIVE_THEMING": true,

    "COMPREHENSIVE_THEME_DIRS": [
        "/edx/app/edxapp/edx-platform/themes",
        "/edx/src/edly-edx-themes"
    ]

3. Update assets in the docker shell from the ``/edx/app/edxapp/edx-platform`` folder using this command.

.. code:: sh

    paver update_assets


4. Exit the docker shell using ``Ctrl+D`` or ``exit`` command.
5. Restart studio container.

.. code:: sh

    make studio-restart

6. Go to http://localhost:18010/admin and login using ``edx`` as username and ``edx`` as password.
7. Go to http://localhost:18010/admin/sites/site/ and add a new site with values domain as ``localhost:18010`` and display name as ``st-lutherx``.
8. Go to http://localhost:18010/admin/theming/sitetheme/ and add a new theme with values site as ``localhost:18010`` and Theme dir name as ``st-lutherx``.

Set up Edly Open edX theme for Ecommerce
****************************************

1. Go to devstack directory and get into ecommerce container.

.. code:: sh

    cd devstack
    make ecommerce-shell


2. Edit the ``/edx/etc/ecommerce.yml`` file in the docker container and set the following
variables to the following values.

.. code:: json

    "ENABLE_COMPREHENSIVE_THEMING": true,

    COMPREHENSIVE_THEME_DIRS:
    - /edx/src/edly-edx-themes/st-lutherx/ecommerce
    - /edx/src/edly-edx-themes/st-normanx/ecommerce

3. Update assets in the docker shell from the ``/edx/app/ecommerce/ecommerce`` folder using these commands.

.. code:: sh

    python manage.py update_assets
    make requirements

4. Exit the docker shell using ``Ctrl+D`` or ``exit`` command.

5. Restart ecommerce container.

.. code:: sh

    docker-compose restart ecommerce

6. Go to http://localhost:18130/admin and login using ``edx`` as username and ``edx`` as password.
7. Go to http://localhost:18130/admin/sites/site/ and add a new site with values domain as ``localhost:18130`` and display name as ``st-lutherx``.
8. Go to http://localhost:18130/admin/theming/sitetheme/ and add a new theme with values site as ``localhost:18130`` and Theme dir name as ``st-lutherx``.


WordPress Setup
---------------

Gulp should be installed before proceeding further (you may need to skip sudo if you are using nvm).

.. code:: sh

    sudo npm i -g gulp-cli

1. Install php and composer in host machine.

.. code:: sh

    apt-get install php7.2
    curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/bin/composer

**NOTE** If you are on macOS, use following command to move the ``composer.phar`` file.

.. code:: sh

    brew install php@7.2
    curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer


then install composer in wordpress container.

.. code:: sh

    make wordpress-shell
    curl -s https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer


2. Change the owner of ``wp-content`` directory inside docker container.

.. code:: sh

    chown -R www-data:www-data wp-content


3. Install the requirements for ``edly-wp-theme`` and ``edly-wp-plugin`` inside wordpress shell. But before doing that, Change the owner of the directories as shown below.

.. code:: sh

    cd /var/www/html/wp-content/plugins/edly-wp-plugin
    composer install

    cd /var/www/html/wp-content/themes/st-lutherx
    composer install

    cd /var/www/html/wp-content/themes/st-normanx
    composer install

    exit

4. Add ``127.0.0.1 wordpress.edx.devstack.lms`` in host file.
5. Visit ``wordpress.edx.devstack.lms:8888``. It should prompt the WordPress installation screen.
6. Fill it in with the following values

.. code:: sh

        Site name: Edly
        Username: edx
        Password: edx
        Email: edx@example.com

7. Click Install and then login with the same credentials.
8. Change the permissions of ``edly-wp-plugin`` and ``edly-wp-theme``.

.. code:: sh

    cd ..
    sudo chmod -R 0777 edly-wp-plugin
    sudo chmod -R 0777 edly-wp-theme
    cd devstack

9. Run wordpress provsion.

.. code:: sh

    ./provision-wordpress.sh

**Note** (For Linux): If you face an error related to xml while running the provision, run the following command:

.. code:: sh

        sudo apt-get install php7.2-xml

and then run the provision again.

10. Go to devstack folder and run `make lms-shell` and edit the config file ``../lms.env.json``. Change the below value

.. code:: sh

        "SESSION_COOKIE_DOMAIN": ".edx.devstack.lms"


To setup **Wordpress Pages** (Home, Blog, Courses, Instructors, About, Contact, FAQ) go to Wordpress panel and do the following steps for each page

- Go to "Pages" -> "Add New" page.
- Add page title.
- In "Page Attributes" section and click on "Template" select field. Select the appropriate template for the page.
- Publish the Page.
- Now click on "Edit with Elementor" button.
- On Elementor page, add any new templates or use existing ones for widgets if required, apply required changes (Images and sections) and click "Publish".

Now your page is published.

Steps to **setup ``Home``** page are shown below for explainatory purposes.

1. Log into WordPress admin panel.
2. Go to "All Pages" -> "Add New" page.
3. Set the title "Home".
4. Select "Home" template from "Template" select field.
5. Click on "Edit with Elementor" button.
6. In the widget area, click on ``directory`` icon.
7. Go to "My Template" tab.
8. Click on "Import Template" icon in upper left corner of the section
9. Now select ``<devstack-dir>/edly-wp-theme/theme-name/config-files/elementor-home.json`` file and import it.
10. Click on "Insert" button for ``Home`` template that we have just imported.
11. Click on "Edit Section" icon of the first widget appeared.
12. From the sidebar, go to "style" tab and upload an image of your choice.
13. Click on "Publish" button to save changes in Elementor.
14. Click on "Exit to Dashboard" from side menu.
15. Publish the page.

Now we can repeat the steps for the pages we want to setup.

To set the Home page we just setup as **default home page** perform the following steps.

1. Log into WordPress admin panel.
2. Go to "Appearance" -> "Customize" page.
3. Click on "Homepage settings"
4. Select "A static page" option.
5. Select "Home" in Homepage field.
6. Click publish.

To add **Course Additional Fields** follow the steps below:

1. Log into WordPress admin panel.
2. Go to "Custom Fields" -> "Tools" page.
3. In "Import Field Groups", select and import ``<devstack>/edly-wp-theme/config-files/acf-export-english.json`` file.

Setup WordPress Single Sign On
------------------------------
To setup the single sing on(SSO) on WordPress.  Follow the below steps

1. Open WordPress Shell

.. code:: sh

        make wordpress-shell

2. Open `wp-config.php` file

.. code:: sh

        apt update

        apt install nano

        nano wp-config.php


3. Past the below code and save file

.. code:: sh

        define( 'EDLY_SSO_CLIENT_ID', 'edly-wordpress-key' );

        define( 'EDLY_SSO_CLIENT_SECRET', 'edly-wordpress-secret' );

        define( 'EDLY_SSO_AUTHORIZE_ENDPOINT', 'http://edx.devstack.lms:18000/oauth2/authorize' );

        define( 'EDLY_SSO_ACCESS_TOKEN_URL', 'http://edx.devstack.lms:18000/oauth2/access_token' );

        define( 'EDLY_SSO_SCOPE', 'openid+profile+email+permissions' );

        define( 'EDLY_SSO_REDIRECT_URL', 'http://wordpress.edx.devstack.lms:8888' );

        define( 'EDLY_SOCIAL_AUTH_EDX_OIDC_ISSUER', 'http://localhost:18000/oauth2' );


4. Go to `LMS Django Admin` -> `Oauth2` -> `Clients`

- Add new client.

- Select ``discovery_worker`` in Users field

- Add ``edly-wordpress`` in Name field

- Add ``http://wordpress.edx.devstack.lms:8888`` in Url field

- Add ``http://wordpress.edx.devstack.lms:8888`` in Redirect Uri field

- Add ``edly-wordpress-key`` in Client Id field

- Add ``edly-wordpress-secret`` in Client Secret

- Select ``Confidential Web applications`` in Client type field

- Add ``http://wordpress.edx.devstack.lms:8888/logout`` in Logout uri field.


5. Go to WordPress admin area. Add new page with the name of Logout and select the `Logout` template.


Setting up edly panel
---------------------

1. Make sure all the edly services (Wordpress, LMS, Studio, Ecommerce, Course discovery) have been setup using the
edly devstack ironwood branch.

2. Clone edly panel backend locally in a separate folder than edly.

.. code:: sh

    mkdir ~/workspace/edly-panel-backend
    cd ~/workspace/edly-panel-backend

3. Follow all the steps from https://github.com/edly-io/edly-panel-backend/tree/develop.

4. Follow Step 4 onwards from this link. https://edlyio.atlassian.net/wiki/spaces/PI/pages/297500692/How+to+setup+Edly+Panel

**NOTE** If you have already installed the ``edly-panel-edx-app``, skip step 11.

Enable Marketing URLs
---------------------

1. Go to lms container.

.. code:: sh

    make lms-shell
    nano ../lms.env.json

and set the ``ENABLE_MKTG_SITE`` feature flag to ``True``.

2. Add the following URLs in ``edx-platform/lms/envs/devstack_docker.py``

.. code:: python

    MKTG_URLS = {
        ...
            "NAV_MENU": "wp-json/edly-wp-routes/nav-menu",
            "FOOTER": "wp-json/edly-wp-routes/footer",
            "ZENDESK-WIDGET": "wp-json/edly-wp-routes/edly-zendesk-widget"
        }



Enable Course Creation
----------------------

Go to ``<devstack-dir>/edx-platform/cms/envs/common.py`` and add
the following code to ``FEATURES`` dictionary.

.. code:: python

    # show organizations in studio while creating new course
    'ORGANIZATIONS_APP': True

Other useful commands
---------------------

After the services have started, if you need shell access to one of the
services, run ``make <service>-shell``. For example to access the
Catalog/Course Discovery Service, you can run:

.. code:: sh

    make discovery-shell

To see logs from containers running in detached mode, you can either use
"Kitematic" (available from the "Docker for Mac" menu), or by running the
following:

.. code:: sh

    make logs

To view the logs of a specific service container run ``make <service>-logs``.
For example, to access the logs for Ecommerce, you can run:

.. code:: sh

    make ecommerce-logs

To reset your environment and start provisioning from scratch, you can run:

.. code:: sh

    make destroy

For information on all the available ``make`` commands, you can run:

.. code:: sh

    make help

Usernames and Passwords
-----------------------

The provisioning script creates a Django superuser for every service.

::

    Email: edx@example.com
    Username: edx
    Password: edx

The LMS also includes demo accounts. The passwords for each of these accounts
is ``edx``.

+------------+------------------------+
| Username   | Email                  |
+============+========================+
| audit      | audit@example.com      |
+------------+------------------------+
| honor      | honor@example.com      |
+------------+------------------------+
| staff      | staff@example.com      |
+------------+------------------------+
| verified   | verified@example.com   |
+------------+------------------------+

Getting Started on Analytics
----------------------------

Analyticstack can be run by following the steps below.

**NOTE:** Since a Docker-based devstack runs many containers, you should configure
Docker with a sufficient amount of resources. We find that
`configuring Docker for Mac`_ with a minimum of 2 CPUs and 6GB of memory works
well for **analyticstack**. If you intend on running other docker services besides
analyticstack ( e.g. lms, studio etc ) consider setting higher memory.

1. Follow steps `1` and `2` from `Getting Started`_ section.

2. Before running the provision command, make sure to pull the relevant
   docker images from dockerhub by running the following commands:

   .. code:: sh

       make pull
       make pull.analytics_pipeline

3. Run the provision command to configure the analyticstack.

   .. code:: sh

       make dev.provision.analytics_pipeline

4. Start the analytics service. This command will mount the repositories under the
   DEVSTACK\_WORKSPACE directory.

   **NOTE:** it may take up to 60 seconds for Hadoop services to start.

   .. code:: sh

       make dev.up.analytics_pipeline

5. To access the analytics pipeline shell, run the following command. All analytics
   pipeline job/workflows should be executed after accessing the shell.

   .. code:: sh

     make analytics-pipeline-shell

   - To see logs from containers running in detached mode, you can either use
     "Kitematic" (available from the "Docker for Mac" menu), or by running the
     following command:

      .. code:: sh

        make logs

   - To view the logs of a specific service container run ``make <service>-logs``.
     For example, to access the logs for Hadoop's namenode, you can run:

      .. code:: sh

        make namenode-logs

   - To reset your environment and start provisioning from scratch, you can run:

      .. code:: sh

        make destroy

     **NOTE:** Be warned! This will remove all the containers and volumes
     initiated by this repository and all the data ( in these docker containers )
     will be lost.

   - For information on all the available ``make`` commands, you can run:

      .. code:: sh

        make help

6. For running acceptance tests on docker analyticstack, follow the instructions in the
   `Running analytics acceptance tests in docker`_ guide.
7. For troubleshooting docker analyticstack, follow the instructions in the
   `Troubleshooting docker analyticstack`_ guide.

Service URLs
------------

Each service is accessible at ``localhost`` on a specific port. The table below
provides links to the homepage of each service. Since some services are not
meant to be user-facing, the "homepage" may be the API root.

+---------------------+-------------------------------------+
| Service             | URL                                 |
+=====================+=====================================+
| Panel Frontend      | http://localhost:3030/              |
+---------------------+-------------------------------------+
| Credentials         | http://localhost:18150/api/v2/      |
+---------------------+-------------------------------------+
| Catalog/Discovery   | http://localhost:18381/api-docs/    |
+---------------------+-------------------------------------+
| E-Commerce/Otto     | http://localhost:18130/dashboard/   |
+---------------------+-------------------------------------+
| LMS                 | http://localhost:18000/             |
+---------------------+-------------------------------------+
| Notes/edx-notes-api | http://localhost:18120/api/v1/      |
+---------------------+-------------------------------------+
| Studio/CMS          | http://localhost:18010/             |
+---------------------+-------------------------------------+

Useful Commands
---------------

Sometimes you may need to restart a particular application server. To do so,
simply use the ``docker-compose restart`` command:

.. code:: sh

    docker-compose restart <service>

``<service>`` should be replaced with one of the following:

-  credentials
-  discovery
-  ecommerce
-  lms
-  edx_notes_api
-  studio

If you'd like to add some convenience make targets, you can add them to a ``local.mk`` file, ignored by git.

Payments
--------

The ecommerce image comes pre-configured for payments via CyberSource and PayPal. Additionally, the provisioning scripts
add the demo course (``course-v1:edX+DemoX+Demo_Course``) to the ecommerce catalog. You can initiate a checkout by visiting
http://localhost:18130/basket/add/?sku=8CF08E5 or clicking one of the various upgrade links in the LMS. The following
details can be used for checkout. While the name and address fields are required for credit card payments, their values
are not checked in development, so put whatever you want in those fields.

- Card Type: Visa
- Card Number: 4111111111111111
- CVN: 123 (or any three digits)
- Expiry Date: 06/2025 (or any date in the future)

PayPal (same for username and password): devstack@edx.org

Marketing Site
--------------

Docker Compose files useful for integrating with the edx.org marketing site are
available. This will NOT be useful to those outside of edX. For details on
getting things up and running, see
https://openedx.atlassian.net/wiki/display/OpenDev/Marketing+Site.

How do I develop on an installed Python package?
------------------------------------------------

If you want to modify an installed package – for instance ``edx-enterprise`` or ``completion`` – clone the repository in
``~/workspace/src/your-package``. Next, ssh into the appropriate docker container (``make lms-shell``),
run ``pip install -e /edx/src/your-package``, and restart the service.


How do I build images?
----------------------

There are `Docker CI Jenkins jobs`_ on tools-edx-jenkins that build and push new
Docker images to DockerHub on code changes to either the configuration repository or the IDA's codebase. These images
are tagged according to the branch from which they were built (see NOTES below).
If you want to build the images on your own, the Dockerfiles are available in the ``edx/configuration`` repo.

NOTES:

1. edxapp and IDAs use the ``latest`` tag for configuration changes which have been merged to master branch of
   their repository and ``edx/configuration``.
2. Images for a named Open edX release are built from the corresponding branch
   of each repository and tagged appropriately, for example ``hawthorn.master``
   or ``hawthorn.rc1``.
3. The elasticsearch used in devstack is built using elasticsearch-devstack/Dockerfile and the ``devstack`` tag.

BUILD COMMANDS:

.. code:: sh

    git checkout master
    git pull
    docker build -f docker/build/edxapp/Dockerfile . -t edxops/edxapp:latest

.. code:: sh

    git checkout master
    git pull
    docker build -f docker/build/ecommerce/Dockerfile . -t edxops/ecommerce:devstack

The build commands above will use your local configuration, but will pull
application code from the master branch of the application's repository. If you
would like to use code from another branch/tag/hash, modify the ``*_VERSION``
variable that lives in the ``ansible_overrides.yml`` file beside the
``Dockerfile``. Note that edx-platform is an exception; the variable to modify is ``edx_platform_version``
and not ``EDXAPP_VERSION``.

For example, if you wanted to build tag ``release-2017-03-03`` for the
E-Commerce Service, you would modify ``ECOMMERCE_VERSION`` in
``docker/build/ecommerce/ansible_overrides.yml``.

How do I run the images for a named Open edX release?
-----------------------------------------------------

1. Set the ``OPENEDX_RELEASE`` environment variable to the appropriate image
   tag; "hawthorn.master", "zebrawood.rc1", etc.  Note that unlike a server
   install, ``OPENEDX_RELEASE`` should not have the "open-release/" prefix.
2. Use ``make dev.checkout`` to check out the correct branch in the local
   checkout of each service repository once you've set the ``OPENEDX_RELEASE``
   environment variable above.
3. ``make pull`` to get the correct images.

All ``make`` target and ``docker-compose`` calls should now use the correct
images until you change or unset ``OPENEDX_RELEASE`` again.  To work on the
master branches and ``latest`` images, unset ``OPENEDX_RELEASE`` or set it to
an empty string.

How do I create database dumps?
-------------------------------
We use database dumps to speed up provisioning and generally spend less time running migrations. These dumps should be
updated occasionally - when database migrations take a prolonged amount of time *or* we want to incorporate changes that
require manual intervention.

To update the database dumps:

1. Destroy and/or backup the data for your existing devstack so that you start with a clean slate.
2. Disable the loading of the existing database dumps during provisioning by commenting out any calls to ``load-db.sh``
   in the provisioning scripts. This disabling ensures a start with a completely fresh database and incorporates any changes
   that may have required some form of manual intervention for existing installations (e.g. drop/move tables).
3. Provision devstack with ``make provision``.
4. Dump the databases and open a pull request with your updates:

.. code:: sh

   ./dump-db.sh ecommerce
   ./dump-db.sh edxapp
   ./dump-db.sh edxapp_csmh

How do I keep my database up to date?
-------------------------------------

You can run Django migrations as normal to apply any changes recently made
to the database schema for a particular service.  For example, to run
migrations for LMS, enter a shell via ``make lms-shell`` and then run:

.. code:: sh

   paver update_db

Alternatively, you can discard and rebuild the entire database for all
devstack services by re-running ``make dev.provision`` or
``make dev.sync.provision`` as appropriate for your configuration.  Note that
if your branch has fallen significantly behind master, it may not include all
of the migrations included in the database dump used by provisioning.  In these
cases, it's usually best to first rebase the branch onto master to
get the missing migrations.

How do I access a database shell?
---------------------------------

To access a MySQL or Mongo shell, run the following commands, respectively:

.. code:: sh

   make mysql-shell
   mysql

.. code:: sh

   make mongo-shell
   mongo

How do I make migrations?
-------------------------

Log into the LMS shell, source the ``edxapp`` virtualenv, and run the
``makemigrations`` command with the ``devstack_docker`` settings:

.. code:: sh

   make lms-shell
   source /edx/app/edxapp/edxapp_env
   cd /edx/app/edxapp/edx-platform
   ./manage.py <lms/cms> makemigrations <appname> --settings=devstack_docker

Also, make sure you are aware of the `Django Migration Don'ts`_ as the
edx-platform is deployed using the red-black method.


How do I upgrade Node.JS packages?
----------------------------------

JavaScript packages for Node.js are installed into the ``node_modules``
directory of the local git repository checkout which is synced into the
corresponding Docker container.  Hence these can be upgraded via any of the
usual methods for that service (``npm install``,
``paver install_node_prereqs``, etc.), and the changes will persist between
container restarts.

How do I upgrade Python packages?
---------------------------------

Unlike the ``node_modules`` directory, the ``virtualenv`` used to run Python
code in a Docker container only exists inside that container.  Changes made to
a container's filesystem are not saved when the container exits, so if you
manually install or upgrade Python packages in a container (via
``pip install``, ``paver install_python_prereqs``, etc.), they will no
longer be present if you restart the container.  (Devstack Docker containers
lose changes made to the filesystem when you reboot your computer, run
``make down``, restart or upgrade Docker itself, etc.) If you want to ensure
that your new or upgraded packages are present in the container every time it
starts, you have a few options:

* Merge your updated requirements files and wait for a new `edxops Docker image`_
  for that service to be built and uploaded to `Docker Hub`_.  You can
  then download and use the updated image (for example, via ``make pull``).
  The discovery and edxapp images are buit automatically via a Jenkins job. All other
  images are currently built as needed by edX employees, but will soon be built
  automatically on a regular basis. See `How do I build images?`_
  for more information.
* You can update your requirements files as appropriate and then build your
  own updated image for the service as described above, tagging it such that
  ``docker-compose`` will use it instead of the last image you downloaded.
  (Alternatively, you can temporarily edit ``docker-compose.yml`` to replace
  the ``image`` entry for that service with the ID of your new image.) You
  should be sure to modify the variable override for the version of the
  application code used for building the image. See `How do I build images?`_.
  for more information.
* You can temporarily modify the main service command in
  ``docker-compose.yml`` to first install your new package(s) each time the
  container is started.  For example, the part of the studio command which
  reads ``...&& while true; do...`` could be changed to
  ``...&& pip install my-new-package && while true; do...``.
* In order to work on locally pip-installed repos like edx-ora2, first clone
  them into ``../src`` (relative to this directory). Then, inside your lms shell,
  you can ``pip install -e /edx/src/edx-ora2``. If you want to keep this code
  installed across stop/starts, modify ``docker-compose.yml`` as mentioned
  above.

How do I rebuild static assets?
-------------------------------

Optimized static assets are built for all the Open edX services during
provisioning, but you may want to rebuild them for a particular service
after changing some files without re-provisioning the entire devstack.  To
do this, run the make target for the appropriate service.  For example:

.. code:: sh

   make credentials-static

To rebuild static assets for all service containers:

.. code:: sh

   make static

Switching branches
------------------

You can usually switch branches on a service's repository without adverse
effects on a running container for it.  The service in each container is
using runserver and should automatically reload when any changes are made
to the code on disk.  However, note the points made above regarding
database migrations and package updates.

When switching to a branch which differs greatly from the one you've been
working on (especially if the new branch is more recent), you may wish to
halt the existing containers via ``make down``, pull the latest Docker
images via ``make pull``, and then re-run ``make dev.provision`` or
``make dev.sync.provision`` in order to recreate up-to-date databases,
static assets, etc.

If making a patch to a named release, you should pull and use Docker images
which were tagged for that release.

Changing LMS/CMS settings
-------------------------
The LMS and CMS read many configuration settings from the container filesystem
in the following locations:

- ``/edx/app/edxapp/lms.env.json``
- ``/edx/app/edxapp/lms.auth.json``
- ``/edx/app/edxapp/cms.env.json``
- ``/edx/app/edxapp/cms.auth.json``

Changes to these files will *not* persist over a container restart, as they
are part of the layered container filesystem and not a mounted volume. However, you
may need to change these settings and then have the LMS or CMS pick up the changes.

To restart the LMS/CMS process without restarting the container, kill the LMS or CMS
process and the watcher process will restart the process within the container. You can
kill the needed processes from a shell within the LMS/CMS container with a single line of bash script:

LMS:

.. code:: sh

    kill -9 $(ps aux | grep 'manage.py lms' | egrep -v 'while|grep' | awk '{print $2}')

CMS:

.. code:: sh

    kill -9 $(ps aux | grep 'manage.py cms' | egrep -v 'while|grep' | awk '{print $2}')

From your host machine, you can also run ``make lms-restart`` or
``make studio-restart`` which run those commands in the containers for you.

PyCharm Integration
-------------------

See the `Pycharm Integration documentation`_.

devpi Caching
-------------

LMS and Studio use a devpi container to cache PyPI dependencies, which speeds up several Devstack operations.
See the `devpi documentation`_.

Debugging using PDB
-------------------

It's possible to debug any of the containers' Python services using PDB. To do so,
start up the containers as usual with:

.. code:: sh

    make dev.up

This command starts each relevant container with the equivalent of the '--it' option,
allowing a developer to attach to the process once the process is up and running.

To attach to the LMS/Studio containers and their process, use either:

.. code:: sh

    make lms-attach
    make studio-attach

Set a PDB breakpoint anywhere in the code using:

.. code:: sh

    import pdb;pdb.set_trace()

and your attached session will offer an interactive PDB prompt when the breakpoint is hit.

To detach from the container, you'll need to stop the container with:

.. code:: sh

    make stop

or a manual Docker command to bring down the container:

.. code:: sh

   docker kill $(docker ps -a -q --filter="name=edx.devstack.<container name>")

Running LMS and Studio Tests
----------------------------

After entering a shell for the appropriate service via ``make lms-shell`` or
``make studio-shell``, you can run any of the usual paver commands from the
`edx-platform testing documentation`_.  Examples:

.. code:: sh

    paver run_quality
    paver test_a11y
    paver test_bokchoy
    paver test_js
    paver test_lib
    paver test_python

Tests can also be run individually. Example:

.. code:: sh

    pytest openedx/core/djangoapps/user_api

Connecting to Browser
**********************

If you want to see the browser being automated for JavaScript or bok-choy tests,
you can connect to the container running it via VNC.

+------------------------+----------------------+
| Browser                | VNC connection       |
+========================+======================+
| Firefox (Default)      | vnc://0.0.0.0:25900  |
+------------------------+----------------------+
| Chrome (via Selenium)  | vnc://0.0.0.0:15900  |
+------------------------+----------------------+

On macOS, enter the VNC connection string in the address bar in Safari to
connect via VNC. The VNC passwords for both browsers are randomly generated and
logged at container startup, and can be found by running ``make vnc-passwords``.

Most tests are run in Firefox by default.  To use Chrome for tests that normally
use Firefox instead, prefix the test command with
``SELENIUM_BROWSER=chrome SELENIUM_HOST=edx.devstack.chrome``.

Running End-to-End Tests
------------------------

To run the base set of end-to-end tests for edx-platform, run the following
make target:

.. code:: sh

   make e2e-tests

If you want to use some of the other testing options described in the
`edx-e2e-tests README`_, you can instead start a shell for the e2e container
and run the tests manually via paver:

.. code:: sh

    make e2e-shell
    paver e2e_test --exclude="whitelabel\|enterprise"

The browser running the tests can be seen and interacted with via VNC as
described above (Firefox is used by default).

Troubleshooting: General Tips
-----------------------------

If you are having trouble with your containers, this sections contains some troubleshooting tips.

Check the logs
**************

If a container stops unexpectedly, you can look at its logs for clues::

    docker-compose logs lms

Update the code and images
***************************

Make sure you have the latest code and Docker images.

Pull the latest Docker images by running the following command from the devstack
directory:

.. code:: sh

   make pull

Pull the latest Docker Compose configuration and provisioning scripts by running
the following command from the devstack directory:

.. code:: sh

   git pull

Lastly, the images are built from the master branches of the application
repositories (e.g. edx-platform, ecommerce, etc.). Make sure you are using the
latest code from the master branches, or have rebased your branches on master.

Clean the containers
********************

Sometimes containers end up in strange states and need to be rebuilt. Run
``make down`` to remove all containers and networks. This will **NOT** remove your
data volumes.

Reset
*****

Sometimes you just aren't sure what's wrong, if you would like to hit the reset button
run ``make dev.reset``.

Running this command will perform the following steps:

* Bring down all containers
* Reset all git repositories to the HEAD of master
* Pull new images for all services
* Compile static assets for all services
* Run migrations for all services

It's good to run this before asking for help.

Start over
**********

If you want to completely start over, run ``make destroy``. This will remove
all containers, networks, AND data volumes.

Resetting a database
********************

In case you botched a migration or just want to start with a clean database.

1. Open up the mysql shell and drop the database for the desired service::

    make mysql-shell
    mysql
    DROP DATABASE (insert database here)

2. From your devstack directory, run the provision script for the service. The
   provision script should handle populating data such as Oauth clients and
   Open edX users and running migrations::

    ./provision-(service_name)


Troubleshooting: Common issues
------------------------------

File ownership change
**********************

If you notice that the ownership of some (maybe all) files have changed and you
need to enter your root password when editing a file, you might
have pulled changes to the remote repository from within a container. While running
``git pull``, git changes the owner of the files that you pull to the user that runs
that command. Within a container, that is the root user - so git operations
should be ran outside of the container.

To fix this situation, change the owner back to yourself outside of the container by running:

.. code:: sh

  $ sudo chown <user>:<group> -R .

Running LMS commands within a container
****************************************

Most of the ``paver`` commands require a settings flag. If omitted, the flag defaults to
``devstack``, which is the settings flag for vagrant-based devstack instances.
So if you run into issues running ``paver`` commands in a docker container, you should append
the ``devstack_docker`` flag. For example:

.. code:: sh

  $ paver update_assets --settings=devstack_docker

Resource busy or locked
************************

While running ``make static`` within the ecommerce container you could get an error
saying:

.. code:: sh

  Error: Error: EBUSY: resource busy or locked, rmdir '/edx/app/ecommerce/ecommerce/ecommerce/static/build/'

To fix this, remove the directory manually outside of the container and run the command again.

No space left on device
************************

If you see the error ``no space left on device`` on a Mac, Docker has run
out of space in its Docker.qcow2 file.

Here is an example error while running ``make pull``:

.. code:: sh

   ...
   32d52c166025: Extracting [==================================================>] 1.598 GB/1.598 GB
   ERROR: failed to register layer: Error processing tar file(exit status 1): write /edx/app/edxapp/edx-platform/.git/objects/pack/pack-4ff9873be2ca8ab77d4b0b302249676a37b3cd4b.pack: no space left on device
   make: *** [pull] Error 1

Try this first to clean up dangling images:

.. code:: sh

   docker image prune -f  # (This is very safe, so try this first.)

If you are still seeing issues, you can try cleaning up dangling volumes.

**Warning**: In most cases this will only remove volumes you no longer need, but
this is not a guarantee.

.. code:: sh

   docker volume prune -f  # (Be careful, this will remove your persistent data!)


No such file or directory
**************************

While provisioning, some have seen the following error:

.. code:: sh

   ...
   cwd = os.getcwdu()
   OSError: [Errno 2] No such file or directory
   make: *** [dev.provision.run] Error 1

This issue can be worked around, but there's no guaranteed method to do so.
Rebooting and restarting Docker does *not* seem to correct the issue. It
may be an issue that is exacerbated by our use of sync (which typically speeds
up the provisioning process on Mac), so you can try the following:

.. code:: sh

   # repeat the following until you get past the error.
   make stop
   make dev.provision

Once you get past the issue, you should be able to continue to use sync versions
of the make targets.

Memory Limit
************

While provisioning, some have seen the following error:

.. code:: sh

   ...
   Build failed running pavelib.assets.update_assets: Subprocess return code: 137

This error is an indication that your docker process died during execution.  Most likely,
this error is due to running out of memory.  Try increasing the memory
allocated to Docker.

Docker is using lots of CPU time when it should be idle
*********************************************************

On the Mac, this often manifests as the ``hyperkit`` process using a high
percentage of available CPU resources.  To identify the container(s)
responsible for the CPU usage:

.. code:: sh

    make stats

Once you've identified a container using too much CPU time, check its logs;
for example:

.. code:: sh

    make lms-logs

The most common culprit is an infinite restart loop where an error during
service startup causes the process to exit, but we've configured
``docker-compose`` to immediately try starting it again (so the container will
stay running long enough for you to use a shell to investigate and fix the
problem).  Make sure the set of packages installed in the container matches
what your current code branch expects; you may need to rerun ``pip`` on a
requirements file or pull new container images that already have the required
package versions installed.

Performance
-----------

Improve Mac OSX Performance with docker-sync
**********************************************

Docker for Mac has known filesystem issues that significantly decrease
performance for certain use cases, for example running tests in edx-platform. To
improve performance, `Docker Sync`_  can be used to synchronize file data from
the host machine to the containers.

Many developers have opted not to use `Docker Sync`_ because it adds complexity
and can sometimes lead to issues with the filesystem getting out of sync.

You can swap between using Docker Sync and native volumes at any time, by using
the make targets with or without 'sync'. However, this is harder to do quickly
if you want to switch inside the PyCharm IDE due to its need to rebuild its
cache of the containers' virtual environments.

If you are using macOS, please follow the `Docker Sync installation
instructions`_ before provisioning.

Docker Sync Troubleshooting tips
*********************************
Check your version and make sure you are running 0.4.6 or above:

.. code:: sh

    docker-sync --version

If not, upgrade to the latest version:

.. code:: sh

    gem update docker-sync

If you are having issues with docker sync, try the following:

.. code:: sh

    make stop
    docker-sync stop
    docker-sync clean

Cached Consistency Mode
************************

The performance improvements provided by `cached consistency mode for volume
mounts`_ introduced in Docker CE Edge 17.04 are still not good enough. It's
possible that the "delegated" consistency mode will be enough to no longer need
docker-sync, but this feature hasn't been fully implemented yet (as of
Docker 17.12.0-ce, "delegated" behaves the same as "cached").  There is a
GitHub issue which explains the `current status of implementing delegated consistency mode`_.

.. _Docker Compose: https://docs.docker.com/compose/
.. _Docker for Mac: https://docs.docker.com/docker-for-mac/
.. _Docker for Windows: https://docs.docker.com/docker-for-windows/
.. _Docker Sync: https://github.com/EugenMayer/docker-sync/wiki
.. _Docker Sync installation instructions: https://github.com/EugenMayer/docker-sync/wiki/1.-Installation
.. _cached consistency mode for volume mounts: https://docs.docker.com/docker-for-mac/osxfs-caching/
.. _current status of implementing delegated consistency mode: https://github.com/docker/for-mac/issues/1592
.. _configuring Docker for Mac: https://docs.docker.com/docker-for-mac/#/advanced
.. _feature added in Docker 17.05: https://github.com/edx/configuration/pull/3864
.. _edx-e2e-tests README: https://github.com/edx/edx-e2e-tests/#how-to-run-lms-and-studio-tests
.. _edxops Docker image: https://hub.docker.com/r/edxops/
.. _Docker Hub: https://hub.docker.com/
.. _Pycharm Integration documentation: docs/pycharm_integration.rst
.. _devpi documentation: docs/devpi.rst
.. _edx-platform testing documentation: https://github.com/edx/edx-platform/blob/master/docs/testing.rst#running-python-unit-tests
.. _docker-sync: #improve-mac-osx-performance-with-docker-sync
.. _docker-ce: https://docs.docker.com/install/linux/docker-ce/ubuntu/
.. |Build Status| image:: https://travis-ci.org/edx/devstack.svg?branch=master
    :target: https://travis-ci.org/edx/devstack
    :alt: Travis
.. _Docker CI Jenkins Jobs: https://tools-edx-jenkins.edx.org/job/DockerCI
.. _How do I build images?: https://github.com/edx/devstack/tree/master#how-do-i-build-images
   :target: https://travis-ci.org/edx/devstack
.. _Django Migration Don'ts: https://engineering.edx.org/django-migration-donts-f4588fd11b64
.. _Python virtualenv: http://docs.python-guide.org/en/latest/dev/virtualenvs/#lower-level-virtualenv
.. _Running analytics acceptance tests in docker: http://edx-analytics-pipeline-reference.readthedocs.io/en/latest/running_acceptance_tests_in_docker.html
.. _Troubleshooting docker analyticstack: http://edx-analytics-pipeline-reference.readthedocs.io/en/latest/troubleshooting_docker_analyticstack.html
