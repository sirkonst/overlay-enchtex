# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit ssl-cert eutils

DESCRIPTION="Web setup vz-server"
HOMEPAGE="http://wiki.enchtex.info"
SRC_URI="http://updata.enchtex.info/projects/web-server/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86"

IUSE="nginx php mysql ftp postgres"

DEPEND="enchtex-servers/base-server
app-admin/apache-tools
app-arch/unzip
ftp? ( net-ftp/proftpd )
nginx? ( www-servers/nginx )
php? ( dev-lang/php dev-php5/suhosin dev-php5/eaccelerator www-servers/spawn-fcgi )
mysql? ( dev-db/mysql
	php? ( dev-db/phpmyadmin ) )
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_install() {
	if use ftp ; then
		insinto /etc/proftpd
		doins ${S}/etc/proftpd/proftpd.conf
		insinto /etc/xinetd.d
		doins ${S}/etc/xinetd.d/proftpd
	fi

	if use nginx ; then
		insinto /etc/nginx
		doins ${S}/etc/nginx/fastcgi_params
		doins ${S}/etc/nginx/nginx.conf
		doins ${S}/etc/nginx/ssl.conf
		doins ${S}/etc/nginx/ssl_only.conf

		insinto /etc/logrotate.d
		doins ${S}/etc/logrotate.d/nginx

		keepdir /etc/nginx/vhost.avail
		keepdir /etc/nginx/vhost.d
		keepdir	/etc/nginx/ssl

		insinto /usr/share/eselect/modules
		doins ${FILESDIR}/nginx.eselect

		#keepdir /var/run/spawn-fcgi
		#fperms 777 /var/run/spawn-fcgi

		insinto /etc/vhosts
		doins ${S}/etc/vhosts/webapp-config

		if use php ; then
			newconfd "${S}"/etc/conf.d/spawn-fcgi.admin spawn-fcgi.admin
			dosym spawn-fcgi /etc/init.d/spawn-fcgi.admin

			if use mysql ; then
				insinto /etc/nginx/vhost.avail
				doins "${S}"/etc/nginx/vhost.avail/000_phpmyadmin_vhost.conf
				insinto /var/www/localhost/htdocs/phpmyadmin
				doins "${S}"/var/www/localhost/htdocs/phpmyadmin/config.inc.php
			fi
			if use postgres ; then
				insinto /etc/nginx/vhost.avail
				doins "${S}"/etc/nginx/vhost.avail/000_phppgadmin_vhost.conf
			fi
		fi
	fi

	if use mysql ; then
		exeinto /root/cron-scripts
		newexe ${S}/root/cron-scripts/automysqlbackup.cron 01_automysqlbackup.cron
		newexe ${S}/root/cron-scripts/mysql_optimized.cron 02_mysql_optimized.cron
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
		  if use postgres ; then
			   einfo
			   einfo "For enable postgres edit config vhost /etc/nginx/vhost.avail/000_phppgadmin_vhost.conf"
			   einfo "and than run: >> eselect nginx enable 000_phppgadmin_vhost.conf"
			   einfo
		  fi
	 fi
}

pkg_config() {
	 einfo "test"
}