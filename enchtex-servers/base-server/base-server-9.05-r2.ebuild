# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Basic setup vz-server"
HOMEPAGE="http://wiki.enchtex.info"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86"

IUSE="linguas_ru"

DEPEND="app-portage/gentoolkit
app-portage/portage-utils
sys-process/vixie-cron
app-admin/syslog-ng
app-admin/logrotate
app-i18n/enca
net-analyzer/ngrep
net-dns/bind-tools
sys-process/htop
net-analyzer/tcpdump
app-misc/screen"

RDEPEND="${DEPEND}"

BASE_PACKAGE=0

src_unpack() {
	if [[ "${BASE_PACKAGE}" == 1 ]] ; then
		unpack ${A}
	fi
}

src_install() {
	insinto "${ROOT}"

	for i in ${LINGUAS}; do
		i="${i/_/-}"
		if [[ ${i} = "ru" ]] ; then
			newenvd "${FILESDIR}/02locale" "02locale"
		fi
	done

	insinto /etc
	newins "${FILESDIR}"/motd-${PVR} motd

	dodir /etc/portage/package.use
	dosym /usr/portage/local/overlay-enchtex/profiles/package.use /etc/portage/package.use/000_enchtex.default.use

	dodir /etc/portage/package.keywords
	dosym /usr/portage/local/overlay-enchtex/profiles/package.keywords /etc/portage/package.keywords/000_enchtex.default.keywords

	dodir /etc/portage/package.mask
	dosym /usr/portage/local/overlay-enchtex/profiles/package.mask /etc/portage/package.mask/000_enchtex.default.mask
}
