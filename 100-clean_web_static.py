#!/usr/bin/python3
"""This module contains functions that can be used to
    generates a .tgz archive from the contents of the web_static and
    distributes an archive to your web servers
"""
from fabric.api import local, env
from fabric.operations import run, put
from fabric.context_managers import lcd, cd
from datetime import datetime
from os import path

env.hosts = ['35.196.35.103', '34.75.67.159']


def do_pack():
    """Generates a .tgz archive from the contents of the web_static.
    Returns:
        return the archive path if the archive has been correctly generated.
        Otherwise, it should return None.
    """
    t = datetime.now()
    formated = "{}{}{}{}{}{}".format(t.year, t.month, t.day,
                                     t.hour, t.minute, t.second)
    file = "versions/web_static_{}.tgz".format(formated)

    local('mkdir -p versions')
    local('tar -czvf {} web_static/'.format(file))

    if path.exists(file):
        return file
    return None


def do_deploy(archive_path):
    """Distributes an archive to your web servers.
    Args:
        archive_path (str): tgz path.
    Returns:
        boolean: true if successful and false otherwise.
    """

    noext = archive_path.replace(".tgz", "").split("/")[1]
    if not path.exists(archive_path):
        return False

    try:
        put('{}'.format(archive_path), '/tmp/')
        archive_path = archive_path.split("/")[1]

        server_dir = "/data/web_static/releases/{}".format(noext)
        run('mkdir -p {}'.format(server_dir))

        run(' tar -xzf /tmp/{} -C {}'.format(archive_path, server_dir))
        run('rm /tmp/{}'.format(archive_path))
        run('mv {}/web_static/* {}/'.format(server_dir, server_dir))
        run('rm -rf {}/web_static'.format(server_dir))
        run('unlink /data/web_static/current')
        run('ln -s {} /data/web_static/current'.format(server_dir))
    except Exception:
        return False
    return True


def deploy():
    """Deploy a new version.
    Returns:
        boolean: True if deploy succeeded, False otherwise.
    """
    file_path = do_pack()
    if file_path is None:
        return False
    return do_deploy(file_path)


def do_clean(number=0):
    """Deletes out-of-date archives.
    Args:
        number (int, optional): option. Defaults to 0.
    """
    if int(number) <= 1:
        number = 2
    else:
        number = int(number) + 1
    with lcd('versions/'):
        local('ls -t | grep web_static | tail -n +{} | xargs -r rm'.format(
            number))
    with cd('/data/web_static/releases/'):
        run('ls -t | grep web_static | tail -n +{} | xargs -r rm -r'.format(
            number))
