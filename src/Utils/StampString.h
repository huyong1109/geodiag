#ifndef __Geomtk_StampString__
#define __Geomtk_StampString__

#include "geomtk_commons.h"
#include "TimeManager.h"

namespace geomtk {

enum StampType {
    TIME_STAMP
};

class StampString {
protected:
    string prefix, suffix;
public:
    StampString();
    StampString(const string &prefix, const string &suffix);
    virtual ~StampString();

    string run(const Time &time);
    string run(const string &format, int tag);

    bool operator==(const StampString &other) const;
    
    friend ostream& operator<<(ostream &os, const StampString &stampString) {
        os << stampString.prefix << "<...>" << stampString.suffix;
        return os;
    }
};

}

#endif