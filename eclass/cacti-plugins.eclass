# Copyright 2008-2009 Chris Gianelloni
# Distributed under the terms of the GNU General Public License v2
# $Id$

#
# Original Author: Chris Gianelloni <wolf31o2@wolf31o2.org>
# Purpose: Provide a framework for installing Cacti plugins via the Cacti
# Plugin Architecture patch.

# We don't actually need webapp-config for this.
WEBAPP_OPTIONAL="yes"
WEBAPP_MANUAL_SLOT="yes"

inherit eutils mysql-dbfuncs webapp

case "${EAPI:-0}" in
	0|1)
		EXPORT_FUNCTIONS pkg_setup src_install pkg_postinst
		DEPEND=">=net-analyzer/cacti-0.8.7b-r4"
		;;
	*)
		EXPORT_FUNCTIONS src_install pkg_postinst
		DEPEND=">=net-analyzer/cacti-0.8.7d-r2[pluginarch]"
		;;
esac

# Variables to specify in an ebuild which uses this eclass:
# TODO: Add this section's docs
export CACTI_HOME=${CACTI_HOME:-/var/www/localhost/htdocs/cacti}
export CACTI_SQL_DBNAME=${CACTI_SQL_DBNAME:-cacti}

export CACTI_PLUG_BASE="http://mirror.cactiusers.org/downloads/plugins"
export CACTI_PLUG_NAME=${PN}
export CACTI_PLUG_HOME=${CACTI_HOME}/plugins/${CACTI_PLUG_NAME}

export MYSQL_DBNAME=${CACTI_SQL_DBNAME}

DESCRIPTION="Cacti plugin: ${CACTI_PLUG_NAME}"
HOMEPAGE="http://docs.cacti.net/plugins"

if [ -z "${MY_P}" ] ; then MY_P="${PN}_v${PV}" ; fi
SRC_URI="http://docs.cacti.net/_media/plugin:${PN}_v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""
RESTRICT="primaryuri"

RDEPEND="${DEPEND}"

cacti-plugins_cleanup_php_adodb_includes() {
	## TODO:  check if we have options passed
	einfo "Switching to system ADOdb"
	sed -i -e \
		's:$config\["library_path"\] . "/adodb/adodb.inc.php":"adodb/adodb.inc.php":' \
		"$@" || die "Failed sed for adodb"
}

cacti-plugins_cleanup_php_config_includes() {
	## TODO:  check if we have options passed
	einfo "Switching from config.php to global.php"
	sed -i -e \
		's:/include/config.php:/include/global.php:' \
		"$@" || die "Failed sed for config.php"
}

cacti-plugins_cleanup_php_eol_style() {
	## TODO:  check if we have options passed
	edos2unix "$@" || die "Failed dos2unix conversion"
}

cacti-plugins_cleanup_svn_leftovers() {
	einfo "Removing useless .svn directories."
	__svndirs=`find "${D}" -type d -name .svn`
	rm -rf ${__svndirs} || die "Cannot clean .svn directories"
}

cacti-plugins_pkg_setup() {
	if has_version \<net-analyzer/cacti-0.8.7d-r2 ; then
		if built_with_use --missing ok \>=net-analyzer/cacti-0.8.7d-r2 plugins pluginarch; then
			einfo "Found Cacti Plugin Architecture"
		else
			die "Need net-anaylzer/cacti with USE=pluginarch"
		fi
	fi
}

cacti-plugins_src_install() {
	local __phpfiles=`find -type f -name '*.php'`
	insinto ${CACTI_PLUG_HOME}

	cacti-plugins_cleanup_php_eol_style ${__phpfiles}
	cacti-plugins_cleanup_php_adodb_includes ${__phpfiles}
	doins -r * || die "Failed installing"
	cacti-plugins_cleanup_svn_leftovers
}

cacti-plugins_pkg_postinst() {
	### TODO: make this *way* smarter
	if [ -n "${PLUGIN_NEEDS_SQL}" ] ; then
		if [ -n "${DO_MYSQL_INSTALL}" ] ; then
			if [ -n "${MYSQL_SCRIPTS}" ] ; then
				MYSQL_SCRIPTS="${CACTI_PLUG_HOME}/${MYSQL_SCRIPTS}"
				mysql-dbfuncs_load_sql
			else
				eerror "MYSQL_SCRIPTS is empty!"
			fi
		else
			elog "You need to import ${MYSQL_SCRIPTS} into your Cacti database."
		fi
	fi
	if [ -n "${PLUGIN_NEEDS_CONFIG}" ] ; then
		elog "You need to add ${PN} to your plugins variable."
	fi
}

