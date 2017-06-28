package com.flopcode.dotstar.android.parameters;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.SeekBar;
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
public class RangeParameter extends Parameter {
  public final Float min;
  public final Float max;

  public RangeParameter(Map<String, String> map) {
    super(map);
    min = new Float(map.get("min"));
    max = new Float(map.get("max"));
  }

  @Override
  public View createButton(LayoutInflater inflater, ViewGroup rootView, final Context context) {
    final Button res = (Button) inflater.inflate(R.layout.preset_color_button, rootView, false);
    res.setText(name);
    res.setOnClickListener(new View.OnClickListener() {
      float value = min;

      @Override
      public void onClick(View view) {
        SeekBar seekBar = new SeekBar(context);
        seekBar.setMax((int) ((max - min) * 10));
        final AlertDialog alertDialog = new AlertDialog.Builder(context)
          .setTitle(calculateTitle())
          .setView(seekBar)
          .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
            }
          })
          .create();
        alertDialog.show();
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
          @Override
          public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
            System.out.println("seekBar = " + seekBar);
            value = (i / 10.0f) + min;
            alertDialog.setTitle(calculateTitle());
            Call<Void> call = getDotStar(getConnectionPrefs(context)).set(ImmutableMap.of(name, String.format("%.1f", value)));
            call.enqueue(new Callback<Void>() {
              @Override
              public void onResponse(Call<Void> call, Response<Void> response) {
                Log.i(Index.LOG_TAG, "could set range for '" + name + "'");
              }

              @Override
              public void onFailure(Call<Void> call, Throwable t) {
                Log.e(Index.LOG_TAG, "could not set range for '" + name + "'", t);
              }
            });
          }

          @Override
          public void onStartTrackingTouch(SeekBar seekBar) {

          }

          @Override
          public void onStopTrackingTouch(SeekBar seekBar) {

          }
        });
      }

      private String calculateTitle() {
        return "Range " + name + "(" + String.format("%.1f", value) + "/" + min + " - " + max + ")";
      }
    });
    return res;
  }
}
