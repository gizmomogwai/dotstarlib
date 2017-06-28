package com.flopcode.dotstar.android;

import java.io.Serializable;
import java.util.Map;

public class Preset implements Serializable {
  public final String name;
  public final Map<String, String> parameters[];

  public Preset(String name, Map<String, String> parameters[]) {
    this.name = name;
    this.parameters = parameters;
  }
}
