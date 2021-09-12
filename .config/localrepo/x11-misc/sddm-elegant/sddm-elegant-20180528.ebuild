# Copyright 2019-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A simple sddm theme"
HOMEPAGE="https://github.com/surajmandalcell/Elegant-sddm"

COMMIT=732499b59aa861528949123ff8037367a4ae1e4a
SRC_URI="https://github.com/surajmandalcell/Elegant-sddm/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64 x86"
S="${WORKDIR}/Elegant-sddm-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"

# RDEPEND="
#	media-libs/phonon:=[gstreamer]
#	media-libs/gst-plugins-good
#	dev-qt/qtmultimedia:=[alsa,gstreamer,qml,widgets]
#	dev-qt/qtgraphicaleffects
#	dev-qt/qtquickcontrols
# "

RDEPEND="
	dev-qt/qtgraphicaleffects
"
src_install() {
	insinto /usr/share/sddm/themes/
	doins -r Elegant
	# dodir /usr/share/sddm/themes/
	# cp -R "${S}/Elegant" "${D}/" || die "Install failed!"
}
