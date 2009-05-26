# KolosStudio.Ru

inherit webapp depend.php

DESCRIPTION="Kolos CMS"
HOMEPAGE="http://www.kolosstudio.ru"
SRC_URI="http://ks-cms.ru/kolos-cms-0.1.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
IUSE=""

need_httpd_cgi
need_php_httpd

S="${WORKDIR}"

pkg_setup () {
	webapp_pkg_setup
	#require_php_with_use mysql
}

src_install () {
	webapp_src_preinst

	insinto "${MY_HTDOCSDIR}"
	doins -r .

	#local files="cnf css images js modules templates uploads index.php"
	 #
	#for file in ${files}; do
	#	webapp_serverowned "${MY_HTDOCSDIR}"/${file}
	#done

	webapp_configfile "${MY_HTDOCSDIR}"/cnf/db_config.php
	#webapp_serverowned "${MY_HTDOCSDIR}"/configuration.php

	#webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt
	webapp_src_install
}
