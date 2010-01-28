# Copyright 2008-2009 Chris Gianelloni
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: cacti.eclass
# @MAINTAINER:
# wolf31o2@wolf31o2.org
# @BLURB: framework for installing Cacti by using functions
# @DESCRIPTION:
# This eclass sets up the Cacti application, provides sensible defaults, and
# allows other packages to get information about the Cacti installation on the
# system.
#
# The intention is to allow installation either using webapp.eclass for the
# interface, or to install it as a standalone application, allowing it to be
# used simply as a polling engine/proxy, without having to use separate
# packages to provide the required functionality.

DESCRIPTION="based on cacti.eclass"

# Sets up the default Cacti settings.  These may be overridden by a package or
# the user, so make sure to allow this in your packages.
#
# Default location for Cacti (system install)
export CACTI_HOME=${CACTI_HOME:-/var/www/localhost/htdocs/cacti}

# Default DB setup
export CACTI_SQL_DBNAME=${CACTI_SQL_DBNAME:-cacti}
export CACTI_SQL_DBHOST=${CACTI_SQL_DBHOST:-localhost}
export CACTI_SQL_DBUSER=${CACTI_SQL_DBUSER:-cactiuser}
export CACTI_SQL_DBPASS=${CACTI_SQL_DBPASS:-cactiuser}
export CACTI_SQL_DBPORT=${CACTI_SQL_DBPORT:-3306}
export CACTI_SQL_DBTYPE=${CACTI_SQL_DBTYPE:-mysql}

# We may not need webapp-config for this
WEBAPP_OPTIONAL="yes"
WEBAPP_MANUAL_SLOT="yes"

inherit eutils mysql-dbfuncs webapp

