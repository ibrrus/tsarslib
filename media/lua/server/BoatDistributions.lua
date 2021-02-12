require "CommonTemplates/CommonDistributions"

local distributionTable = VehicleDistributions[1]

distributionTable["BoatSailingYacht"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}
	
distributionTable["BoatSailingYacht"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}

distributionTable["BoatSailingYachtWithSailsLeft"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}

distributionTable["BoatSailingYachtWithSailsRight"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}

distributionTable["BoatMotor"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}

distributionTable["TrailerWithBoatSailingYacht"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}
	
distributionTable["TrailerWithBoatMotor"] = {
	Normal = VehicleDistributions.CommonTemplatesDist,
}

table.insert(VehicleDistributions, 1, distributionTable);


