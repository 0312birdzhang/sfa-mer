%define strip /bin/true
%define __requires_exclude  ^.*$
%define __find_requires     %{nil}
%global debug_package       %{nil}
%define __provides_exclude_from ^.*$
%define device_rpm_architecture_string armv7hl
%define _target_cpu %{device_rpm_architecture_string}

Name:          audioflingerglue
Summary:       Android AudioFlinger glue library
Version:       XXX
Release:       1
Group:         System/Libraries
License:       ASL 2.0
#BuildRequires: ubu-trusty
#BuildRequires: sudo-for-abuild
#BuildRequires: droid-bin-src-full
Source0:       %{name}-%{version}.tgz
AutoReqProv:   no

%description
%{summary}

%package       devel
Summary:       audioflingerglue development headers
Group:         System/Libraries
Requires:      audioflingerglue = %{version}-%{release}
BuildArch:     noarch

%description   devel
%{summary}

%prep

%if %{?device_rpm_architecture_string:0}%{!?device_rpm_architecture_string:1}
echo "device_rpm_architecture_string is not defined"
exit -1
%endif

%setup

#sudo chown -R abuild:abuild /home/abuild/src/droid/
#mv /home/abuild/src/droid/* .
#mkdir -p external
#pushd external
#tar -zxf %SOURCE0
#mv audioflingerglue* audioflingerglue
#popd
%build
pwd
ls 
tar -xvf %name-%version.tgz
%install

mkdir -p $RPM_BUILD_ROOT/%{_libexecdir}/droid-hybris/system/lib/
mkdir -p $RPM_BUILD_ROOT/%{_libexecdir}/droid-hybris/system/bin/
mkdir -p $RPM_BUILD_ROOT/%{_includedir}/audioflingerglue/
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/audioflingerglue/
pushd %name-%version
cp out/target/product/*/system/lib/libaudioflingerglue.so \
    $RPM_BUILD_ROOT/%{_libexecdir}/droid-hybris/system/lib/

cp out/target/product/*/system/bin/miniafservice \
    $RPM_BUILD_ROOT/%{_libexecdir}/droid-hybris/system/bin/

cp external/audioflingerglue/audioflingerglue.h $RPM_BUILD_ROOT/%{_includedir}/audioflingerglue/
cp external/audioflingerglue/hybris.c $RPM_BUILD_ROOT/%{_datadir}/audioflingerglue/

popd
%files
%defattr(-,root,root,-)
%{_libexecdir}/droid-hybris/system/lib/libaudioflingerglue.so
%{_libexecdir}/droid-hybris/system/bin/miniafservice

%files devel
%defattr(-,root,root,-)
%{_includedir}/audioflingerglue/*.h
%{_datadir}/audioflingerglue/hybris.c
