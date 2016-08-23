package com.flopcode.dotstar.android;

import java.io.Serializable;
import java.util.Map;

public class Preset implements Serializable {
    public final long id;
    public final String name;
    public final Map<String, String> parameters[];

    public Preset(long id, String name, Map<String, String> parameters[]) {
        this.id = id;
        this.name = name;
        this.parameters = parameters;
    }
}
