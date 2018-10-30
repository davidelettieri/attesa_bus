import 'package:html/dom.dart';

class AtacPageParser {
  static AtacFermataInfo parse(String s) {
        try {
          Document d = Document.html(s);


          var nomeFermata = d.getElementsByClassName("lbl-fermata-nome")[0].querySelector("label");

          var allLinee = d.getElementsByClassName("box-linea-percorso-clean");

          var result = new AtacFermataInfo();

          result.Nome = nomeFermata.innerHtml;

          if (allLinee.length > 0) {

            var first = allLinee[0];

            var parent = first.parent.querySelectorAll("*");


            for (var i=0; i<parent.length; i++) {
              var n = parent[i];

              if (n.classes.contains("box-linea-percorso-clean")) {
                var a = n.getElementsByClassName("lbl-linea-percorso-nome")[0];
                var linea = new AtacLinea();
                linea.Nome = a.innerHtml;
                result.Linee.add(linea);
              }
              else if (n.classes.contains("box-previsioni-informazioni")) {
                var a = n.querySelectorAll("*")[1];

                result.Linee.last.TempiAttesa.add(a.innerHtml);
              }
            }
          }

          return result;
        }
        catch(e) {
          var r = new AtacFermataInfo();
          r.Nome = "Fermata non trovata, riprovare.";
          return r;
        }

  }
}

class AtacFermataInfo {
  String Nome;
  List<AtacLinea> Linee;

  AtacFermataInfo() {
    Linee = new List<AtacLinea>();
    Nome = "";
  }

}

class AtacLinea {
  String Nome;
  List<String> TempiAttesa;

  AtacLinea() {
    Nome = "";
    TempiAttesa = new List<String>();
  }
}