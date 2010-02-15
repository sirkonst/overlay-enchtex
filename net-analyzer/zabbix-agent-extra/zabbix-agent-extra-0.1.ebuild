# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Extra plugins for Zabbix agent"
HOMEPAGE="http://wiki.enchtex.info/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86 amd64"

#IUSE="mysql"

DEPEND="net-analyzer/zabbix[agent]"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
	keepdir /etc/zabbix/scripts

	exeinto /etc/zabbix/scripts
	newexe ${FILESDIR}/mysql_stat-${PV}.sh
}

pkg_postinst() {
	einfo
	einfo "For configure run:"
	einfo "$ cat 'UserParameter=mysql[*],/etc/zabbix/scripts/mysql_stat.sh $1' >> /etc/zabbix/zabbix_agentd.conf"
	einfo "and restart zabbix-agent:"
	einfo "$ /etc/init.d/zabbix-agentd restart"
	einfo
}
