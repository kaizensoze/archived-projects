/*
File: clientCommon.js
Description: common shared functions in entire app.
Author: JC Nesci
*/


// Return team colors.
function getTeamColor( team ) {

  var color = "black";

  switch(team) {

    case "seahawks":
      color = "#71D54A";
      break;

    case "eagles":
      color = "#006666";
      break;

    case "cardinals":
      color = "#870619";
      break;

    case "broncos":
      color = "#FB4F14";
      break;

    case "patriots":
      // blue
      // color = "#0D254C";
      // red
      color = "#C80815";
      break;

    case "packers":
      color = "#FFCC00";
      break;

    case "bengals":
      color = "#000000";
      break;

    case "colts":
      color = "#003B7B";
      break;

    case "cowboys":
      // grey
      color = "#8C8B8A";
      // blue
      // color = "#002244";
      break;

    case "lions":
      color = "#006DB0";
      break;

    case "ravens":
      color = "#280353";
      break;

    case "panthers":
      color = "#0088CE";
      break;

    default:
      color = "black";
  }

  return color;
}
