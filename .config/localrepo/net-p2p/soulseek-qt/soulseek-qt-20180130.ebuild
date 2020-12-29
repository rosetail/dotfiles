# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop

DESCRIPTION="Official binary Qt SoulSeek client"
HOMEPAGE="http://www.soulseekqt.net/"
BINARY_NAME="SoulseekQt-${PV:0:4}-$((${PV:4:2}))-$((${PV:6:2}))"
SRC_URI="https://www.slsknet.org/SoulseekQT/Linux/${BINARY_NAME}-64bit-appimage.tgz"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="
	sys-fs/fuse
	media-libs/libpng
	x11-libs/libX11
	x11-libs/libxcb
	media-libs/freetype
	x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/libbsd
	sys-libs/libselinux
	dev-libs/expat"

S="${WORKDIR}"

RESTRICT="mirror"

QA_PREBUILT="opt/bin/.*"

src_install() {
	BINARY_NAME="${BINARY_NAME}-64bit.AppImage"
	into /opt
	newbin "${BINARY_NAME}" "${PN}"
	doicon "${FILESDIR}/soulseek.png"
	domenu "${FILESDIR}/SoulSeek-QT.desktop"
}
