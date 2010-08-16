/**
 * Copyright 2010 Bernard Helyer
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */
module sdc.global;

import std.string;

import sdc.compilererror;
import sdc.util;


shared int versionLevel;
shared bool isDebug;
shared int debugLevel;
shared bool unittestsEnabled;

void setVersion(string s)
{
    if (s in reservedVersionIdentifiers || (s.length >= 2 && s[0 .. 2] == "D_")) {
        error(format("cannot specify reserved version identifier '%s'.", s));
    }
    if (s in versionIdentifiers) {
        error(format("version identifier '%s' already defined.", s));
    }
    versionIdentifiers[s] = true;
}

private void specifyAndReserve(string s)
{
    setVersion(s);
    reservedVersionIdentifiers[s] = true;
}

void setDebug(string s)
{
    if (s in debugIdentifiers) {
        error(format("debug identifier '%s' already defined.", s));
    }
    debugIdentifiers[s] = true;
}

bool isVersionIdentifierSet(string s)
{
    testedVersionIdentifiers[s] = true;
    return (s in versionIdentifiers) !is null;
}

bool hasVersionIdentifierBeenTested(string s)
{
    return (s in testedVersionIdentifiers) !is null;
}

bool isDebugIdentifierSet(string s)
{
    return (s in debugIdentifiers) !is null;
}

static this()
{
    isDebug = true;
    reservedVersionIdentifiers["none"] = true;  // Guaranteed never to be defined.
    specifyAndReserve("all");                   // Guaranteed to be defined by all implementations.
    specifyAndReserve("SDC");                   // Vendor specification.
    versionIdentifiers["D_Version2"] = true;    // D version supported is 2.
}

private shared bool[string] reservedVersionIdentifiers;
private shared bool[string] versionIdentifiers;
private shared bool[string] testedVersionIdentifiers;
private shared bool[string] debugIdentifiers;
