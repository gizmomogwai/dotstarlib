package com.flopcode.dotstar.android;

import org.junit.Test;
import retrofit2.Call;
import retrofit2.Response;

import java.io.DataInputStream;
import java.net.Socket;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

public class DotStarApiTest {
    @Test
    public void testPresetsAreAccessible() throws Exception {
        Call<List<Preset>> h = DotStarApi.createDotStar("http://192.168.0.164:4567/").index();
        Response<List<Preset>> res = h.execute();
        assertThat(res.code()).isEqualTo(200);
        final List<Preset> presets = res.body();
        assertThat(presets.size()).isEqualTo(3);
        final Preset offPreset = presets.get(0);
        assertThat(offPreset.name).isEqualTo("Off");
        final Preset sinPreset = presets.get(1);
        assertThat(sinPreset.name).isEqualTo("Sinuses");
        final Preset midiPreset = presets.get(2);
        assertThat(midiPreset.name).isEqualTo("Midi");
    }

    @Test
    public void testConnectToMidiServer() throws Exception {
        Socket s = new Socket("127.0.0.1", 55554);
        DataInputStream dIn = new DataInputStream(s.getInputStream());
        int i = 0;
        while (i >= 0) {
            int note = dIn.read();
            int volume = dIn.read();
            System.out.println("note = " + note + ", volume = " + volume);
        }
    }
}
