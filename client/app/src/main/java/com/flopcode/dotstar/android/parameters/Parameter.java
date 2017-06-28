package com.flopcode.dotstar.android.parameters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.Map;

public abstract class Parameter {
  public final String name;

  public Parameter(Map<String, String> params) {
    if (!params.containsKey("name")) {
      throw new IllegalArgumentException();
    }
    this.name = params.get("name");
  }

  public abstract View createButton(LayoutInflater inflater, ViewGroup rootView, Context context);
}
