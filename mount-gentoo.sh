#!/usr/bin/bash

GENTOO_ROOT_UUID="cd74cd46-45e1-42aa-8944-a841156a1057"
GENTOO_BOOT_UUID="6160bd37-6eac-4fbc-b625-5ad433128a54"
GENTOO_EFI_UUID="7EEA-DE2E"
GENTOO_FS_ROOT="/mnt/external"

echo "Unmounting ${GENTOO_FS_ROOT}, if mounted."
sudo umount -R --force "${GENTOO_FS_ROOT}" 2>/dev/null 1>/dev/null

! sudo mount "/dev/disk/by-uuid/${GENTOO_ROOT_UUID}" "${GENTOO_FS_ROOT}" &&\
	echo >&2 "Unable to mount Gentoo root." && exit 1

! sudo mount "/dev/disk/by-uuid/${GENTOO_BOOT_UUID}" "${GENTOO_FS_ROOT}/boot" &&\
	echo >&2 echo "Unable to mount Gentoo boot." && exit 1

! sudo mount "/dev/disk/by-uuid/${GENTOO_EFI_UUID}" "${GENTOO_FS_ROOT}/boot/efi" &&\
	echo >&2 "Unable to mount Gentoo EFI partition." && exit 1

! sudo mount -t proc /proc "${GENTOO_FS_ROOT}/proc" && \
    echo >&2 "Unable to mount proc". && exit 1

! sudo mount --rbind /dev "${GENTOO_FS_ROOT}/dev" && \
    echo >&2 "Unable to rbind /dev to ${GENTOO_FS_ROOT}/dev." && exit 1

! sudo mount --make-rslave "${GENTOO_FS_ROOT}/dev" && \
    echo >&2 "Unable to make ${GENTOO_FS_ROOT}/dev an rslave." && exit 1

! sudo mount --rbind /sys "${GENTOO_FS_ROOT}/sys" && \
    echo >&2 "Unable to rbind /sys to ${GENTOO_FS_ROOT}/sys" && exit 1

! sudo mount --make-rslave "${GENTOO_FS_ROOT}/sys" && \
    echo >&2 "Unable to make ${GENTOO_FS_ROOT}/sys an rslave" && exit 1

! sudo mount --rbind /run "${GENTOO_FS_ROOT}/run" && \
    echo >&2 "Unable to rbind /run to ${GENTOO_FS_ROOT}/run" && exit 1

! sudo mount --make-rslave "${GENTOO_FS_ROOT}/run" && \
    echo >&2 "Unable to make ${GENTOO_FS_ROOT}/run an rslave" && exit 1

! sudo cp "/etc/resolv.conf" "${GENTOO_FS_ROOT}/etc" && \
    echo >&2 "Unable to copy /etc/resolv.conf into ${GENTOO_FS_ROOT}/etc.  The chroot will work, but will not be able to access the Internet unless you use the IP of the service you want to contact." && echo >&2

! sudo chroot "${GENTOO_FS_ROOT}" && \
   echo >&2 "Unable to chroot into ${GENTOO_FS_ROOT}"

echo "Unmounting Gentoo..."
! sudo umount -R  --force "${GENTOO_FS_ROOT}" && \
   echo >&2 "Unable to unmount Gentoo" && exit 1
