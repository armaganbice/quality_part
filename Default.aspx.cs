using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Web.Script.Serialization;

namespace TechnicalDrawingApp
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        // This method would handle saving measurements to a database
        // For this example, we'll simulate using a static dictionary
        private static Dictionary<string, List<MeasurementPoint>> measurementsDatabase = new Dictionary<string, List<MeasurementPoint>>();

        // Method to save measurements
        protected void SaveMeasurements(string stockCode, List<MeasurementPoint> points)
        {
            if (measurementsDatabase.ContainsKey(stockCode))
            {
                measurementsDatabase[stockCode] = points;
            }
            else
            {
                measurementsDatabase.Add(stockCode, points);
            }
        }

        // Method to load measurements
        protected List<MeasurementPoint> LoadMeasurements(string stockCode)
        {
            if (measurementsDatabase.ContainsKey(stockCode))
            {
                return measurementsDatabase[stockCode];
            }
            return new List<MeasurementPoint>();
        }

        // JSON serialization helper
        protected string SerializeObject(object obj)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(obj);
        }
    }

    // Measurement point class
    public class MeasurementPoint
    {
        public int Id { get; set; }
        public double X { get; set; }
        public double Y { get; set; }
        public string Value { get; set; }
        public string Description { get; set; }
        public string StockCode { get; set; }
    }
}