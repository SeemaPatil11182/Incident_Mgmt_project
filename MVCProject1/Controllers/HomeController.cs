using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace MVCProject1.Controllers
{
    public class HomeController : Controller
    {

        public ViewResult Demo()
        {
            ViewBag.Countries = new List<string>()
            {
                "India",
                "China",
                "UK",
                "US"
            };
            return View();
        }

    }
}