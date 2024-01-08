import logging
from voeventhandler.extractors.agiledataextractor import AgileDataExtractor
from voeventhandler.extractors.chimedataextractor import ChimeDataExtractor
from voeventhandler.extractors.gcndataextractor import GncDataExtractor
from voeventhandler.extractors.integraldataextractor import IntegralDataExtractor
from voeventhandler.extractors.ligodataextractor import LigoDataExtractor

class VoeventSorting:
    def __init__(self) -> None:
        """
        When the class is created, the extractors are created too
        """
        self.logger = logging.getLogger()
        self.agile = AgileDataExtractor()
        self.chime = ChimeDataExtractor()
        self.gcn = GncDataExtractor()
        self.integral = IntegralDataExtractor()
        self.ligo = LigoDataExtractor()

    def sort(self, voevent):
        """
        This method is used to sort the voevent. 
        The sorting method is based on the field ivorn of the voevent.
        If the instrument is not supported, the method raise an exception.
        """
        ivorn = voevent.attrib['ivorn']
        
        if "gcn" in ivorn:
            self.logger.debug("New GCN notice")
            return (self.gcn.extract(voevent))

        # Handle different networks
        
        if "gwnet" in ivorn:
            self.logger.debug("New LIGO notice")
            return (self.ligo.extract(voevent))

        if "chimenet" in ivorn:
            self.logger.debug("New CHIME notice")
            return (self.chime.extract(voevent))

        if "INTEGRAL" in ivorn:
            self.logger.debug("New INTEGRAL notice")
            return (self.integral.extract(voevent))

        if "AGILE" in ivorn:
            self.logger.debug("New AGILE notice")
            return (self.agile.extract(voevent))
        
        raise Exception(f"Notice not supported, ivorn is {ivorn}")