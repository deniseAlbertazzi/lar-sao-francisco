#!/bin/bash

# This script initializes the Django project. It will be executed at run time.

# Run commands from djang project root folder
cd /code/larsaofrancisco/

# Initial setup
if [ "$1" == "web" ]; then
    # Initialize Django project
    echo "Initialize Django project"
    python manage.py collectstatic --noinput # Do not use --clear, see https://github.com/jschneier/django-storages/issues/436
    python manage.py migrate --noinput

    # (re)compile Translations
    python manage.py compilemessages || echo "Did not find messages to compile (or other error occurred)"

    # Create Superuser
    if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
        echo "Create superuser"
        CREATE="$(python manage.py createsuperuser --noinput --email superuser@superuser.com 2>&1)"
        if [ "$CREATE" == "CommandError: Error: That username is already taken." ]; then
            echo "  Superuser already existed."
        fi
    fi

    if [ "$2" == "local" ]; then
        # Sleep to keep container alive
        echo "Simulate web server start"
        while sleep 1000; do :; done
    else
        #  Start web server
        echo "Starting web server"
        gunicorn settings.wsgi -c gunicorn.conf.py
    fi
    exit $? # Return status code of actual task

elif [ "$1" == "test" ]; then
    # Run Tests
    echo "Running Tests ..."
    sleep 10
    python manage.py test -v 2 --noinput
    exit $?

elif [ "$1" == "openapi-validate" ]; then
    # Validate OpenAPI schema
    echo "Validating OpenAPI schema ..."
    sleep 10

    if [ "$2" == "warnings" ]; then
        python manage.py spectacular --validate --fail-on-warn
    elif [ "$2" == "errors" ]; then
        python manage.py spectacular --validate
    fi

    exit $?

fi

# If none of the above parameter match, execute the parameter as bash command.
# Therefore every task needs to end with exit, otherwise it falls through to here.
exec "$@"
