# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Extra Nagios plugins"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86 amd64"

IUSE=""

DEPEND="net-analyzer/nagios-nrpe[command-args]
net-analyzer/nagios-plugins"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
	keepdir /usr/lib/nagios/plugins/extra

	exeinto /usr/lib/nagios/plugins/extra
	doexe ${FILESDIR}/${PV}/*

	insinto /etc/nagios
	doins ${FILESDIR}/${PV}/nrpe-commands.cfg
}

pkg_postinst() {
	einfo "For configure run:"
	einfo "emerge ${PF} --config"
}

pkg_config() {
	NRPECONF="/etc/nagios/nrpe.cfg"
	NRPECONFOLD="/etc/nagios/nrpe.cfg.old"
	ALLOWEDHOSTS="127.0.0.1"
	COMMANDSCFG="/etc/nagios/nrpe-commands.cfg"

	echo "Configure will be create new /etc/nagios/nrpe.cfg config and backup old"
	echo -n "Do you want to continue? (type: yes): "

	read CONYES

	if [ "$CONYES" != 'yes' ]; then
		echo "Configure canceled."
		exit
	fi

	cp $NRPECONF $NRPECONFOLD
	echo -e "Old config save to $NRPECONFOLD\n"

	echo -e -n "ALLOWED HOST ADDRESSES:\n> "
	read ALLOWEDHOSTS

	sed 's/^dont_blame_nrpe=0/dont_blame_nrpe=1/g' -i $NRPECONF
	sed "s/^allowed_hosts=.*/allowed_hosts=${ALLOWEDHOSTS}/g" -i $NRPECONF
	sed 's/^command/#command/g' -i $NRPECONF
	echo -e "\n# INCLUDE COMMANDS CONFIG" >> $NRPECONF
	echo "include=${COMMANDSCFG}" >> $NRPECONF

	echo -e "\nConfigure done!\n"

	echo "Now run ngrep deamon:"
	echo '$ /etc/init.d/nrpe start'
	echo "and add to autoload:"
	echo '$ rc-update add nrpe default'
}