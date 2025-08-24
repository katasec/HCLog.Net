namespace HCLog.Net.Tests;
using HCLog.Net;


public class UnitTest1
{
    [Fact]
    public void Test1()
    {
        var logger = new HCLogger("MyApp");
        logger.Info("Application started");
    }
}
