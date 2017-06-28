package com.flopcode.dotstar.android.parameters;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import com.flopcode.dotstar.android.Index;
import com.flopcode.dotstar.android.R;
import com.google.common.collect.ImmutableMap;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.util.Map;

import static com.flopcode.dotstar.android.Index.getConnectionPrefs;
import static com.flopcode.dotstar.android.Index.getDotStar;

@SuppressWarnings("unused")
public class BoolParameter extends Parameter {

  public BoolParameter(Map<String, String> params) {
    super(params);
  }

  @Override
  public View createButton(LayoutInflater inflater, ViewGroup rootView, final Context context) {
    final CheckBox res = (CheckBox) inflater.inflate(R.layout.preset_checkbox, rootView, false);
    res.setText(name);
    res.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
      @Override
      public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
        Call<Void> call = getDotStar(getConnectionPrefs(context)).set(ImmutableMap.of(name, "" + b));
        call.enqueue(new Callback<Void>() {
          @Override
          public void onResponse(Call<Void> call, Response<Void> response) {
            Log.i(Index.LOG_TAG, "could set bool for '" + name + "'");
          }

          @Override
          public void onFailure(Call<Void> call, Throwable t) {
            Log.e(Index.LOG_TAG, "could not set bool for '" + name + "'", t);
          }
        });
      }
    });
    return res;
  }
}
