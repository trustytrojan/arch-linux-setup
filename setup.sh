function copy_config {
	for arg in $@; do
 		echo "Copying $arg config"
		cp -r .config/$arg ~/.config
	done
}

PACMAN_OPTS="-Sy --needed"

echo "Installing system-wide bashrc"
sudo cp .bashrc /etc/bash.bashrc

copy_config nvim

read -p "Install pipewire and wireplumber? [Y/n] " pw
[ $pw = n ] || {
	echo "Installing pipewire and wireplumber"
	sudo pacman $PACMAN_OPTS pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
}

read -p "Sway, i3, or no wm? " wm
[ $wm = sway || $wm = i3 ] || exit

# Sway/i3 Shared dependencies
sudo pacman $PACMAN_OPTS gammastep gnome-themes-extra ttc-iosevka dbus polkit-gnome libnotify qpwgraph pavucontrol

# Sway/i3 shared configs
copy_config gammastep gtk-3.0
echo "export GTK_THEME=Adwaita-dark" >> ~/.bashrc

# Determine window manager
read -p "Sway or i3? " wm
case $wm in
	"sway")
		# Require yay installation
		if ! type yay >/dev/null; then
			echo "yay is not installed. Aborting."
			exit 1
		fi
	
		# Install sway dependencies
		yay $PACMAN_OPTS swayfx swayidle swaybg swaylock-effects wofi wl-clipboard foot waybar otf-font-awesome grim slurp
	
		# Copy sway configs
		copy_config foot sway swayidle swaylock waybar
	
		# Set dark theme
		gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"

	"i3")
		# Install i3 dependencies
		sudo pacman $PACMAN_OPTS i3 xorg-server xorg-xinit feh xterm rofi
	
		# Copy configs and X files
		copy_config i3
	 	cp .Xdefaults ~
	  	cp .xinitrc ~
	   	chmod u+x ~/.xinitrc
esac

# Copy wallpaper
cp .wallpaper.jpg ~
