# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Web setup vz-server"
HOMEPAGE="http://wiki.enchtex.info"
SRC_URI="web-server-0.1.tar.bz2"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86"

IUSE="nginx php mysql ftp"

DEPEND="enchtex-servers/base-server
app-admin/apache-tools
app-arch/unzip
ftp? ( net-ftp/proftpd )
nginx? ( www-servers/nginx www-servers/lighttpd )
php? ( dev-lang/php dev-php5/suhosin dev-php5/eaccelerator )
mysql? ( dev-db/mysql
	php? ( dev-db/phpmyadmin ) )
"

RDEPEND="${DEPEND}"

WEB_PACKAGE=1

src_unpack() {
	if [[ "${WEB_PACKAGE}" == 1 ]] ; then
		unpack ${A}
	fi
}

src_install() {
	MYDIR="web-server"

	if use ftp ; then
		insinto /etc/proftpd
		doins ${MYDIR}/etc/proftpd/proftpd.conf
		insinto /etc/xinetd.d
		doins ${MYDIR}/etc/xinetd.d/proftpd
	fi

	if use nginx ; then
		insinto /etc/nginx
		doins ${MYDIR}/etc/nginx/fastcgi_params
		doins ${MYDIR}/etc/nginx/nginx.conf
		keepdir /etc/nginx/sites-available
		keepdir /etc/nginx/sites-enabled

		newconfd "${MYDIR}"/etc/conf.d/spawn-fcgi spawn-fcgi
		doinitd "${MYDIR}"/etc/init.d/spawn-fcgi
		keepdir /var/run/spawn-fcgi
		fperms 777 /var/run/spawn-fcgi

		insinto /etc/vhosts
		doins ${MYDIR}/etc/vhosts/webapp-config

		if use mysql ; then
			if use php ; then
				newconfd "${MYDIR}"/etc/conf.d/spawn-fcgi.admin spawn-fcgi.admin
				dosym spawn-fcgi /etc/init.d/spawn-fcgi.admin
				insinto /etc/nginx/sites-available
				doins "${MYDIR}"/etc/nginx/sites-available/phpmyadmin_vhosts.conf
				insinto /var/www/localhost/htdocs/phpmyadmin
				doins "${MYDIR}"/var/www/localhost/htdocs/phpmyadmin/config.inc.php
			fi
		fi
	fi

	if use mysql ; then
		exeinto /root/cron-scripts
		newexe ${MYDIR}/root/cron-scripts/automysqlbackup.cron 01_automysqlbackup.cron
		newexe ${MYDIR}/root/cron-scripts/mysql_optimized.cron 02_mysql_optimized.cron
		keepdir /var/backup/mysql
	fi
}
