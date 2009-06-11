# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Git-backup"
HOMEPAGE="http://wiki.enchtex.info"
SRC_URI="${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="dev-util/git"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	 unpack ${A}
}

src_install() {
	 cp -R "${S}"/* "${D}/" || die "Install failed!"
}

pkg_postinst() {
	 einfo
}
