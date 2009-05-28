# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit ssl-cert eutils

DESCRIPTION="Web setup vz-server"
HOMEPAGE="http://wiki.enchtex.info"
SRC_URI="web-server-0.2.tar.bz2"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86"

IUSE="nginx php mysql ftp"

DEPEND="enchtex-servers/base-server
app-admin/apache-tools
app-arch/unzip
ftp? ( net-ftp/proftpd )
nginx? ( www-servers/nginx )
php? ( dev-lang/php dev-php5/suhosin dev-php5/eaccelerator www-servers/lighttpd )
mysql? ( dev-db/mysql
	php? ( dev-db/phpmyadmin ) )
"

RDEPEND="${DEPEND}"

WEB_PACKAGE=1

src_unpack() {
	if [[ "${WEB_PACKAGE}" == 1 ]] ; then
		unpack ${A}
	fi

	 epatch ${FILESDIR}/v0.2-patches/0001-logrotate.d-nginx.patch

  #EPATCH_SOURCE="${FILESDIR}/v${PV}-patches" \
  #EPATCH_SUFFIX="patch" \
  #EPATCH_FORCE="yes" epatch
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
		doins ${MYDIR}/etc/nginx/ssl.conf
		doins ${MYDIR}/etc/nginx/ssl_only.conf

		insinto /etc/logrotate.d
		doins ${MYDIR}/etc/logrotate.d/nginx

		keepdir /etc/nginx/vhost.avail
		keepdir /etc/nginx/vhost.d
		keepdir	/etc/nginx/ssl

		insinto /usr/share/eselect/modules
		doins ${FILESDIR}/nginx.eselect

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
				insinto /etc/nginx/vhost.avail
				doins "${MYDIR}"/etc/nginx/vhost.avail/000_phpmyadmin_vhost.conf
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

pkg_postinst() {
	 if use nginx ; then
		  if [ ! -f "${ROOT}"/etc/nginx/ssl/default.key ]; then
			   install_cert /etc/nginx/ssl/default
			   #chown ${PN}:${PN} "${ROOT}"/etc/nginx/ssl/default.{crt,csr,key,pem}
		  fi

		  if use mysql ; then
			   einfo
			   einfo "For enable phpmyadmin edit config vhost /etc/nginx/vhost.avail/000_phpmyadmin_vhost.conf"
			   einfo "and than run: >> eselect nginx enable 000_phpmyadmin_vhost.conf"
			   einfo
		  fi
	 fi
}

pkg_config() {
	 einfo "test"
}