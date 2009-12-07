# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="OpenVZ conlose gui control panel"
HOMEPAGE="http://github.com/sirkonst/vzadmin/"
SRC_URI="http://github.com/sirkonst/vzadmin/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
EAPI="2"

KEYWORDS="x86 amd64"

IUSE=""

DEPEND=">=sys-cluster/vzctl-3.0.23-r2
dev-util/dialog"

RDEPEND="${DEPEND}"

S="${WORKDIR}/sirkonst-vzadmin-f64b781"

src_install() {
	newsbin "${S}/vzadmin.sh" vzadmin
}
