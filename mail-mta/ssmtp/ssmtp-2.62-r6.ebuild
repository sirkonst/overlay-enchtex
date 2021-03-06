# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-mta/ssmtp/ssmtp-2.62-r6.ebuild,v 1.8 2009/07/27 22:06:00 maekke Exp $

inherit eutils toolchain-funcs autotools

DESCRIPTION="Extremely simple MTA to get mail off the system to a Mailhub"
HOMEPAGE="ftp://ftp.debian.org/debian/pool/main/s/ssmtp/"
SRC_URI="mirror://debian/pool/main/s/ssmtp/${P/-/_}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="ssl ipv6 md5sum maxsysuid"

DEPEND="ssl? ( dev-libs/openssl )"
RDEPEND="${DEPEND}
	net-mail/mailbase
	!net-mail/mailwrapper
	!virtual/mta"
PROVIDE="virtual/mta"

S="${WORKDIR}/${PN}"

pkg_setup() {
	enewgroup ssmtp
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Allow to specify the last used system user id, bug #231866
	if use maxsysuid; then
		epatch "${FILESDIR}"/${P}-maxsysuid.patch
		epatch "${FILESDIR}"/${P}-maxsysuid-conf.patch
	fi

	# CVE-2008-3962
	epatch "${FILESDIR}/CVE-2008-3962-r2.patch"

	# Fix AuthPass parsing (bug #238724)
	epatch "${FILESDIR}/${P}-authpass.patch"

	epatch "${FILESDIR}/${P}-strndup.patch"

	# FIX from_format_fix (bug #282907)
	epatch "${FILESDIR}/from_format_fix.path"

	eautoreconf

	# Respect LDFLAGS (bug #152197)
	sed -i -e 's:$(CC) -o:$(CC) @LDFLAGS@ -o:' Makefile.in
}

src_compile() {
	tc-export CC LD

	econf \
		--sysconfdir=/etc/ssmtp \
		$(use_enable ssl) \
		$(use_enable ipv6 inet6) \
		$(use_enable md5sum md5auth) \
		|| die
	make clean || die
	make etcdir=/etc || die
}

src_install() {
	dodir /usr/bin /usr/sbin /usr/lib
	dosbin ssmtp || die
	fperms 755 /usr/sbin/ssmtp

	doman ssmtp.8 ssmtp.conf.5
	dodoc INSTALL README TLS CHANGELOG_OLD
	newdoc ssmtp.lsm DESC

	insinto /etc/ssmtp
	doins ssmtp.conf revaliases

	local conffile="${D}etc/ssmtp/ssmtp.conf"

	# Sorry about the weird indentation, I couldn't figure out a cleverer way
	# to do this without having horribly >80 char lines.
	sed -i -e "s:^hostname=:\n# Gentoo bug #47562\\
# Commenting the following line will force ssmtp to figure\\
# out the hostname itself.\n\\
# hostname=:" \
		"${conffile}" || die "sed failed"

	# Comment rewriteDomain (bug #243364)
	sed -i -e "s:^rewriteDomain=:#rewriteDomain=:" ${conffile}

	# Set restrictive perms on ssmtp.conf as per #187841, #239197
	# Protect the ssmtp configfile from being readable by regular users as it
	# may contain login/password data to auth against a the mailhub used.
	fowners root:ssmtp /etc/ssmtp/ssmtp.conf
	fperms 640 /etc/ssmtp/ssmtp.conf

	fowners root:ssmtp /usr/sbin/ssmtp
	fperms 2711 /usr/sbin/ssmtp

	dosym /usr/sbin/ssmtp /usr/lib/sendmail
	dosym /usr/sbin/ssmtp /usr/bin/sendmail
	dosym /usr/sbin/ssmtp /usr/sbin/sendmail
	dosym /usr/sbin/ssmtp /usr/bin/mailq
	dosym /usr/sbin/ssmtp /usr/bin/newaliases
}
