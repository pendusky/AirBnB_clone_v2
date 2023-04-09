#!/usr/bin/python3
"""Fabric script that generates a .tgz archive from the contents of the
web_static folder of your AirBnB Clone repo"""

from fabric.api import local
from datetime import datetime


def do_pack():
    """Packs the contents of web_static into a tgz archive"""

    local("mkdir -p versions")
    archive_name = "web_static_{}.tgz".format(
        datetime.now().strftime("%Y%m%d%H%M%S"))
    result = local("tar -cvzf versions/{} web_static".format(archive_name))
    if result.failed:
        return None
    return "versions/{}".format(archive_name)

