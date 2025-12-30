// SPDX-License-Identifier: AGPL-3.0-or-later
//! Raw C bindings to libwireguard via @cImport

pub usingnamespace @cImport({
    @cInclude("wireguard.h");
});
