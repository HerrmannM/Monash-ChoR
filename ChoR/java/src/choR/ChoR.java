package choR;

import java.util.BitSet;
import java.util.List;

import core.explorer.*;
import core.graph.ChordalGraph;
import core.model.DecomposableModel;

import static loader.LoadArrays.makeModelData;

/** Proxies for calling Chordalysis methods */

public final class ChoR {

  public static String ChordalysisModellingBudget(int[] nbValuesForAttribute, int[][] data, double pValueThreshold, double budgetShare){
    ChordalysisModeller.Data md = makeModelData(nbValuesForAttribute, data);
    ChordalysisModellingBudget modeller = new ChordalysisModellingBudget(md, pValueThreshold, budgetShare);
    modeller.buildModel();
    return getFormulaString( modeller.getModel() );
  }

  public static String ChordalysisModellingMML(int[] nbValuesForAttribute, int[][] data){
    ChordalysisModeller.Data md = makeModelData(nbValuesForAttribute, data);
    ChordalysisModellingMML modeller = new ChordalysisModellingMML(md);
    modeller.buildModel();
    return getFormulaString( modeller.getModel() );
  }

  public static String ChordalysisModellingSMT(int[] nbValuesForAttribute, int[][] data, double pValueThreshold){
    ChordalysisModeller.Data md = makeModelData(nbValuesForAttribute, data);
    ChordalysisModellingSMT modeller = new ChordalysisModellingSMT(md, pValueThreshold);
    modeller.buildModel();
    return getFormulaString( modeller.getModel() );
  }

  private static String getFormulaString(DecomposableModel model){
    // Access the graph
    ChordalGraph graph = model.graph;
    List<BitSet> cliques = graph.getCliquesBFS();

    // Init string
    String res = "~";

    // For each cliques
    for (BitSet clique : cliques) {
      // Add all item
      for (int var = clique.nextSetBit(0); var >= 0; var = clique.nextSetBit(var + 1)) { res += var + "*"; }
       // remove last "*"
      if(res.endsWith("*")){res = res.substring(0, res.length()-1);}
      res += "+";
    }

    // remove last "+"
    if(res.endsWith("+")){res = res.substring(0, res.length()-1);}

    return res;
  }

}
