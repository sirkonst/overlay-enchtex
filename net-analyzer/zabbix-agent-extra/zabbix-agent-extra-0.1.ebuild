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
	newexe ${FILESDIR}/mysql_stat-${PV}.sh mysql_stat.sh
}

pkg_postinst() {
	einfo
	einfo "For configure run:"
	einfo "$ emerge ${CATEGORY}/${PN} --config"
	einfo
}

pkg_config() {
	einfo "1. Configure MySQL access."
	einfo

	read -rp "MySQL user (root): " USER
	read -rsp "MySQL password: " PASSWD

	sed -i "/^USER=/s:root:${USER:-root}:" /etc/zabbix/scripts/mysql_stat.sh
	sed -i "/^PASSWD=/s:pass:${PASSWD}:" /etc/zabbix/scripts/mysql_stat.sh

	einfo
	einfo "2. Automatic add UserParameter into zabbix agent config."

	ADDCONF='UserParameter=mysql[*],/etc/zabbix/scripts/mysql_stat.sh $1'

	if [ -z "`grep -F "$ADDCONF" /etc/zabbix/zabbix_agentd.conf`" ]; then
		echo -e "\n# MySQL stat parameters:" >> /etc/zabbix/zabbix_agentd.conf
		echo "$ADDCONF" >> /etc/zabbix/zabbix_agentd.conf
	fi

	if [ -z "`grep -F "$ADDCONF" /etc/zabbix/zabbix_agent.conf`" ]; then
		echo -e "\n# MySQL stat parameters:" >> /etc/zabbix/zabbix_agent.conf
		echo "$ADDCONF" >> /etc/zabbix/zabbix_agent.conf
	fi

	einfo
	einfo "3. Restart zabbix agent. Please run:"
	einfo "$ /etc/init.d/zabbix-agentd restart"
}
