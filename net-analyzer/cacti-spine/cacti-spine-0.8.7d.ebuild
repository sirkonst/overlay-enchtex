# Copyright 1999-2008 Gentoo Foundation ; 2008-2009 Chris Gianelloni
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

WANT_AUTOCONF="latest"
inherit autotools eutils

MY_PV=${PV/_p/-}
DESCRIPTION="Spine is a fast poller for Cacti (formerly known as Cactid)"
HOMEPAGE="http://cacti.net/spine_info.php"
SRC_URI="http://forums.cacti.net/download.php?id=17107 -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT=""
IUSE=""

DEPEND="net-analyzer/net-snmp
	>=virtual/mysql-5.0"
RDEPEND="${DEPEND}
	>=net-analyzer/cacti-0.8.7c"

src_configure() {
	cd "${S}"
	sed -i -e 's/^bin_PROGRAMS/sbin_PROGRAMS/' Makefile.am
	sed -i -e 's/wwwroot\/cacti\/log/var\/log/g' spine.h
	sed -i -e 's/Hostnanme/Hostname/g' ping.c
#	epatch "${DISTDIR}"/${P}-phpscript.patch
	eautoreconf
	chmod +x configure
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	exeinto usr/sbin ; doexe "${S}"/spine
	insinto etc/ ; insopts -m0640 -o root -g apache
	newins "${S}"/spine.conf.dist spine.conf || die
	dodoc ChangeLog INSTALL README
}

pkg_postinst() {
	ewarn "NOTE: If you upgraded from cactid, do not forgive to setup spine"
	ewarn "instead of cactid through web interface."
	ewarn
	elog "Please see cacti's site for installation instructions."
	elog "Theres no need to change the crontab for this, just"
	elog "read the instructions on how to implement it"
	elog
	elog "http://cacti.net/spine_install.php"
	echo
	ewarn "/etc/spine.conf should be readable by webserver, thus after you"
	ewarn "decide on webserver/webserver group do not forget to change it's"
	ewarn "group with the following command:"
	ewarn
	ewarn " # chown root:wwwgroup /etc/spine.conf"
	echo
}
