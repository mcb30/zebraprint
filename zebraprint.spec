%global srcname zebraprint
%global pysrcname zebconf
%global cups_datadir %(/usr/bin/cups-config --datadir)
%global cups_filterdir %{_cups_serverbin}/filter

%{?python_enable_dependency_generator}

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
Requires:	python3-%{pysrcname} = %{version}-%{release}
Provides:	zebconf

%package -n python3-%{pysrcname}
Summary:	Zebra CPCL label printer configuration library
BuildRequires:	python3-devel
%{?python_provide:%python_provide python3-%{pysrcname}}

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

%description -n python3-%{pysrcname}
A Python library for configuring Zebra CPCL label printers.

%prep
%autosetup -n %{srcname}-%{version}

%build
%{make_build}
%{py3_build}

%install
mkdir -p $RPM_BUILD_ROOT{%{cups_datadir}/mime,%{cups_filterdir}}
%{make_install} CUPS_DATADIR=$RPM_BUILD_ROOT%{cups_datadir} \
		CUPS_FILTERDIR=$RPM_BUILD_ROOT%{cups_filterdir}
%{py3_install}

%files
%license COPYING
%dir %{cups_datadir}/zebraprint
%{cups_datadir}/zebraprint/cpcl.xsd
%{cups_datadir}/zebraprint/cpcl.xslt
%{cups_datadir}/mime/zebraprint.types
%{cups_datadir}/mime/zebraprint.convs
%{cups_filterdir}/xmltocpcl
%{_bindir}/zebconf

%files -n python3-%{pysrcname}
%license COPYING
%{python3_sitelib}/%{pysrcname}-*.egg-info/
%{python3_sitelib}/%{pysrcname}/

%changelog
{{{ git_dir_changelog }}}
