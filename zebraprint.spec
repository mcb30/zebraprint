%global srcname zebraprint
%global cups_datadir %(/usr/bin/cups-config --datadir)
%global cups_filterdir %{_cups_serverbin}/filter

Name:		{{{ git_dir_name }}}
Version:	{{{ git_dir_version }}}
Release:	1%{?dist}
Summary:	Zebra CPCL label printer support
License:	GPLv2+
URL:		http://github.com/unipartdigital/%{srcname}
VCS:		{{{ git_dir_vcs }}}
Source:		{{{ git_dir_pack }}}
BuildRequires:	gcc
BuildRequires:	libxml2-devel
BuildRequires:	libxslt-devel
BuildRequires:	cups-devel

%description
Zebra printers are supported by the CUPS printing system but only as
raster image devices.  This means that documents to be printed are
sent to the printer as a large raster (bitmap) image.  On some Zebra
printers, this can result in a delay of around 80 seconds before the
label is printed.

A more efficient method is to use the Comtec Printer Control Language
(CPCL).  This is a page description language (analogous to PostScript)
that can be used to describe the page using built-in primitives for
text, barcodes, graphics, etc.

Installing this package will allow you to print CPCL or CPCL/XML
documents directly to your Zebra printer via CUPS.

%prep
%autosetup -n %{srcname}-%{version}

%build
%{make_build}

%install
mkdir -p $RPM_BUILD_ROOT{%{cups_datadir}/mime,%{cups_filterdir}}
%{make_install} CUPS_DATADIR=$RPM_BUILD_ROOT%{cups_datadir} \
		CUPS_FILTERDIR=$RPM_BUILD_ROOT%{cups_filterdir}

%post
systemctl try-restart cups.path cups.socket cups.service &>/dev/null || :

%postun
systemctl try-restart cups.path cups.socket cups.service &>/dev/null || :

%files
%license COPYING
%dir %{cups_datadir}/zebraprint
%{cups_datadir}/zebraprint/cpcl.xsd
%{cups_datadir}/zebraprint/cpcl.xslt
%{cups_datadir}/mime/zebraprint.types
%{cups_datadir}/mime/zebraprint.convs
%{cups_filterdir}/xmltocpcl

%changelog
{{{ git_dir_changelog }}}
