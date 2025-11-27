using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Services;

namespace TechnicalDrawingApp
{
    public partial class PartsManagement : System.Web.UI.Page
    {
        // In a real application, this would be replaced with a database
        private static Dictionary<string, PartData> partsDatabase = new Dictionary<string, PartData>();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetAllParts()
        {
            return partsDatabase.Values.ToList();
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object SearchParts(string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm))
            {
                return partsDatabase.Values.ToList();
            }

            var filteredParts = partsDatabase.Values
                .Where(p => p.StockCode.ToLower().Contains(searchTerm.ToLower()))
                .ToList();

            return filteredParts;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object GetPartByStockCode(string stockCode)
        {
            if (partsDatabase.ContainsKey(stockCode))
            {
                return partsDatabase[stockCode];
            }
            return null;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool SavePart(PartData partData)
        {
            try
            {
                // In a real application, this would save to a database
                partsDatabase[partData.StockCode] = partData;
                return true;
            }
            catch (Exception ex)
            {
                // Log the error in a real application
                return false;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static bool DeletePart(string stockCode)
        {
            try
            {
                if (partsDatabase.ContainsKey(stockCode))
                {
                    partsDatabase.Remove(stockCode);
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                // Log the error in a real application
                return false;
            }
        }
    }

    public class PartData
    {
        public string StockCode { get; set; }
        public string ImageUrl { get; set; }
        public List<MeasurementPoint> Measurements { get; set; }

        public PartData()
        {
            Measurements = new List<MeasurementPoint>();
        }
    }

    public class MeasurementPoint
    {
        public int Id { get; set; }
        public int X { get; set; }
        public int Y { get; set; }
        public string Value { get; set; }
        public string Description { get; set; }
    }
}