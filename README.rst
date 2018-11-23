========
sun-java
========

Formula to set up and configure Java JREs and JDKs from a tarball archive sourced via URL.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.
    
Available states
================

.. contents::
    :local:

``sun-java``
------------

Downloads the tarball from the java:source_url configured as either a pillar or grain and will not do anything
if source_url is omitted. Then unpacks the archive into java:prefix (defaults to /usr/share/java).
Will use the alternatives system to link the installation to java_home. Please see the pillar.example for configuration.

``sun-java.jce``
----------------

Downloads and installs the Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files. Will include/extend the sun-java state.

``sun-java.env``
----------------

An addition to allow easy use - places a java profile in /etc/profile.d - this way JAVA_HOME and the PATH are set correctly for all system users.

``sun-java.cacert``
----------------

An addition to allow install own CA certificates in defined keystore. If no keystore is defined, default in $JAVA_HOME/jre/lib/security/cacerts will be used. If default password for castore has been changed, provide new in pillars.
CA certificates will only be installed if not already in keystore file.

Verified on Linux and MacOS.
