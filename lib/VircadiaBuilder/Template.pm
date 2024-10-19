#!/usr/bin/perl -w
package VircadiaBuilder::Template;

use strict;
use Exporter;
use VircadiaBuilder::Common;
use File::Basename qw(dirname);

our (@EXPORT, @ISA);



BEGIN {
	@ISA = qw(Exporter);
	@EXPORT = qw( );
}

=pod

=head1 NAME

VircadiaBuilder::Template - Templating system

=head1 DESCRIPTION

Simple templating system for generating files with templated contents

=head1 FUNCTIONS

=cut



sub new {
    my ($class, $base_path) = @_;
    my $self = {};
    bless $self, $class;

    $self->{base_path} = $base_path;
    $self->{values} = {};

    $self->fork_name("Overte");
    return $self;
}

=item fork_id($value)

Get/set identifier of the fork. Single word, used for directory names.

Eg, "Overte"

=cut

sub fork_id {
    my ($self, $val) = @_;

    if (defined $val) {
        $self->{fork} = $val;
    }

    return $self->_getset('fork_id', $val);
}


=item fork_name($value)

Get/set name of the fork. Can be multiple words.

Eg, "Overte"

=cut

sub fork_name {
    my ($self, $val) = @_;
    return $self->_getset('fork_name', $val);
}


=item version($value)

Get/set the version

Eg, 1.0

=cut

sub version {
    my ($self, $val) = @_;
    return $self->_getset('version', $val);
}


=item write_appstream($destination, %values)

Writes the AppStream XML to the $destination directory.

$destination must be the root of the AppImage.

Returns the full path to the generated file.

The right filename depends on the fork being used, so this function
will generate and return the right filename when called.

=cut

sub write_appstream {
    my ($self, $appimage_dir, %values) = @_;


    my ($appstream_major, $appstream_minor, $appstream_revision) = $self->get_appstream_version();

    my $appstream_file = "appstream.xml";

    if ($appstream_major < 1) {
        $appstream_file = "appstream-v0.xml";
    }


    my $dest_filename;

    if ( $self->{fork} eq "Overte" ) {
        $dest_filename = "$appimage_dir/usr/share/metainfo/org.overte.interface.appdata.xml";
    } elsif ( $self->{fork} eq "Vircadia" ) {
        $dest_filename = "$appimage_dir/usr/share/metainfo/com.vircadia.interface.appdata.xml";
    } elsif ( $self->{fork} eq "Tivoli" ) {
        $dest_filename = "$appimage_dir/usr/share/metainfo/com.tivolivr.interface.appdata.xml";
    } else {
        die "Unknown fork: $self->{fork}";
    }

    $self->_deploy($appstream_file, $dest_filename, %values);

    return $dest_filename;
}

=item get_appstream_version()

Returns the system's version of the appstream specification.

Used for compatibility.

=cut

sub get_appstream_version {
    my ($self) = @_;

    my $appstream_version = run("/usr/bin/appstreamcli", "--version");
    (undef, $appstream_version) = split(/:/, $appstream_version);
    my ($maj, $min, $rev) = split(/\./, $appstream_version);

    return ($maj, $min, $rev);
}

=item write_appimage_desktop_file($destination, %values)

Writes the .desktop file for an AppImage to the $destination directory.

$destination must be the root of the AppImage.

Returns the full path to the generated file.

=cut

sub write_appimage_desktop_file {
    my ($self, $appimage_dir, %values) = @_;

    my $dest_dir = "$appimage_dir/usr/share/applications";
    my $dest_filename;

    if ( $self->{fork} eq "Overte" ) {
        $dest_filename = "org.overte.interface.desktop";
    } elsif ( $self->{fork} eq "Vircadia" ) {
        $dest_filename = "com.vircadia.interface.desktop";
    } elsif ( $self->{fork} eq "Tivoli" ) {
        $dest_filename = "com.tivolivr.interface.desktop";
    } else {
        die "Unknown fork: '" . $self->{fork} . "'";
    }

    $self->_deploy("appimage.desktop", "$dest_dir/$dest_filename", %values);
    symlink("usr/share/applications/$dest_filename", "$appimage_dir/$dest_filename");


    return "$dest_dir/$dest_filename";

}

=item write_appimage_packaged_qtconf_file($destination, %values)

Writes the qt.conf for an AppImage to the $destination directory when Qt is prepackaged.

This config file tells Qt where to look for its files, and is necessary to make
the AppImage work properly.

This is the pre-packaged Qt version.

$destination must be the root of the AppImage.

Returns the full path to the generated file.

=cut

sub write_appimage_packaged_qtconf_file {
    my ($self, $appimage_dir, %values) = @_;
    my $dest_dir = $appimage_dir;
    my $dest_file = "$dest_dir/overte/interface/qt.conf";

    $self->_deploy("qt.conf", $dest_file, %values);

    return $dest_file;
}

=item write_appimage_apprun_file($destination, %values)

Writes the AppRun for an AppImage.

$destination must be the root of the AppImage.

Returns the full path to the generated file.

=cut

sub write_appimage_apprun_file {
    my ($self, $appimage_dir, %values) = @_;
    my $dest_dir = $appimage_dir;

    $self->_deploy("AppRun", "$dest_dir/AppRun", %values);
    chmod(0755, "$dest_dir/AppRun");

    return "$dest_dir/AppRun";
}


sub _deploy {
    my ($self, $source_file, $destination, %values) = @_;

    local $/;
    undef $/;

    my $file_path = $self->{base_path} . "/templates/" . $self->fork_name . "/${source_file}";
    my $data;

    open(my $fh, '<',  $file_path) or die "Failed to read '$file_path': $!";
    $data = <$fh>;
    close $fh;

    # Process the passed values first, these take priority
    foreach my $k (keys %values) {
        my $v = $values{$k};
        $data =~ s/\$${k}/$v/g;
    }

    # Then the internally stored key/values
    foreach my $k (keys %{$self->{values}} ) {
        my $v = $self->{values}->{$k};
        $data =~ s/\$${k}/$v/g;
    }

    my $dir = dirname($destination);
    mkdir_path($dir);

    open(my $out, '>', $destination) or die "Failed to write to '$destination': $!";
    print $out $data;
    close $out;
}

sub _getset {
    my ($self, $key, $value) = @_;
    my $cur = $self->{values}->{$key};

    if (defined $value) {
        $self->{values}->{$key} = $value;
    }

    return $cur;
}

1;