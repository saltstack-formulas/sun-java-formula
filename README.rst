===
sun-java
===

Formula to set up and configure Oracle JDK/Server JRE as the system java distribution

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``sun-java``

Downloads the tarball from the java:source_url configured as either a pillar or grain (will not do anything if source_url is omitted) and unpacks the package in java:prefix (defaults to /usr/share/java). It will then configure alternatives and place /etc/profile.d/java.sh.  Please see the pillar.example for configuration.

Requires RedHat/CentOS 5.X or RedHat/CentOS 6.X - should also work on Debian/Ubuntu.

