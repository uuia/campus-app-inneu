
import 'package:flutter/material.dart';
import 'package:inneu/components/render.dart';
import 'package:inneu/theme.dart';

class LibraryNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("图书馆导航"),
      ),
      backgroundColor: ThemeRegular.backgroundColor,
      body: SingleChildScrollView(
        child: RenderComponent(
          code: "{\"tag\":\"column\",\"attr\":{\"cross-axis\":\"center\"},\"children\":[{\"tag\":\"container\",\"attr\":{\"margin-left\":\"8\",\"margin-right\":\"8\",\"margin-top\":\"8\",\"margin-bottom\":\"8\",\"padding-left\":\"12\",\"padding-right\":\"12\",\"padding-top\":\"12\",\"padding-bottom\":\"12\",\"color\":\"#FFFFFFFF\",\"radius\":\"10\"},\"children\":[{\"tag\":\"text\",\"attr\":{\"font-size\":\"16\"},\"content\":\"    本室为现刊阅览室，收藏近两年来的西文、俄文、日文现刊和近五年的西文期刊合订本。配备有多台电脑终端供查阅电子文献。（仅供室内阅览，可复印）\"}]},{\"tag\":\"container\",\"attr\":{\"margin-left\":\"8\",\"margin-right\":\"8\",\"margin-top\":\"8\",\"margin-bottom\":\"8\",\"padding-left\":\"12\",\"padding-right\":\"12\",\"padding-top\":\"12\",\"padding-bottom\":\"12\",\"color\":\"#FFFFFFFF\",\"radius\":\"10\"},\"children\":[{\"tag\":\"text\",\"attr\":{\"font-size\":\"16\"},\"content\":\"    本室为现刊阅览室，收藏近两年来的西文、俄文、日文现刊和近五年的西文期刊合订本。配备有多台电脑终端供查阅电子文献。（仅供室内阅览，可复印）\"}]}]}",
          format: "json",
        ),
      ),
    );
  }
}