# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Git-backup"
HOMEPAGE="http://wiki.enchtex.info"
SRC_URI="${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86 amd64"

IUSE=""

DEPEND="dev-util/git"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}

	cd "${S}"

	epatch "${FILESDIR}/v0.2-r1_000-GB_EXCLUDES.patch" || die "patch failed"
	epatch "${FILESDIR}/v0.2-r2_0001-GB_INCLUDES.patch" || die "patch failed"
	epatch "${FILESDIR}/v0.2-r3_0001-last.patch" || die "patch failed"
	epatch "${FILESDIR}/v0.2-r4_0001-fix-last-wrk-with-point.patch" || die "patch failed"
}

src_install() {
	 cp -R "${S}"/* "${D}/" || die "Install failed!"
}

#pkg_postinst() {
#	 einfo
#}
