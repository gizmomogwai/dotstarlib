package com.flopcode.dotstar.android.parameters;

import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.OnColorSelectedListener;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;
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
public class ColorParameter extends Parameter {
  public ColorParameter(Map<String, String> params) {
    super(params);
  }

  @Override
  public View createButton(LayoutInflater inflater, ViewGroup rootView, final Context context) {
    final Button res = (Button) inflater.inflate(R.layout.preset_color_button, rootView, false);
    res.setText(name);
    res.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        showColorPicker();
      }

      private void showColorPicker() {
        ColorPickerDialogBuilder
          .with(context)
          .setTitle("Choose color for " + name)
          .initialColor(0xffffffff)
          .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
          .showAlphaSlider(false)
          .density(30)
          .setOnColorSelectedListener(new OnColorSelectedListener() {
            @Override
            public void onColorSelected(int selectedColor) {

              Call<Void> call = getDotStar(getConnectionPrefs(context)).set(ImmutableMap.of(name, color2String(selectedColor)));
              call.enqueue(new Callback<Void>() {
                @Override
                public void onResponse(Call<Void> call, Response<Void> response) {
                  Log.i(Index.LOG_TAG, "could set color for '" + name + "'");
                }

                @Override
                public void onFailure(Call<Void> call, Throwable t) {
                  Log.e(Index.LOG_TAG, "could not set color for '" + name + "'", t);
                }
              });
            }

            // color is always with full alpha (ff -> to Integer.toHexString always return 8 charachters.
            private String color2String(int color) {
              return "#" + Integer.toHexString(color).substring(2);
            }
          })
          .setPositiveButton("ok", new ColorPickerClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int selectedColor, Integer[] allColors) {
              System.out.println("ok clicked");
            }
          })
          .setNegativeButton("cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
              System.out.println("cancel clicked");
            }
          })
          .build()
          .show();
      }
    });
    return res;
  }
}
