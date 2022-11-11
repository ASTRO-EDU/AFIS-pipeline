from comet.plugins.extractors.templatedataextractor import TemplateDataExtractor
from utilis.instrumentid import InstrumentId
from utilis.voeventdata import Voeventdata
from astropy.coordinates import SkyCoord
from astropy import units as u
import voeventparse as vp

class IntegralDataExtractor(TemplateDataExtractor):

        def __init__(self) -> None:
            super().__init__("integral")

        def extract(self, voevent) -> Voeventdata:
            return super().extract(voevent)

        def is_ste(self, voevent):
            return 1

        def get_instrumentID_and_name(self, voevent) -> tuple:
            return InstrumentId.INTEGRAL.value, "INTEGRAL"

        def get_triggerID(self, voevent):
            top_params = vp.get_toplevel_params(voevent)
            return top_params["TrigID"]["value"]

        def get_packet_type(self, voevent):
            return 0

        def get_networkID(self, voevent):
            return 6

        def get_l_b(self, voevent):
            ra = float(voevent.WhereWhen.ObsDataLocation.ObservationLocation.AstroCoords.Position2D.Value2.C1.text)
            dec = float(voevent.WhereWhen.ObsDataLocation.ObservationLocation.AstroCoords.Position2D.Value2.C2.text)
            c = SkyCoord(ra=ra*u.degree, dec=dec*u.degree, frame='icrs')
            return c.galactic.l.degree, c.galactic.b.degree

        def get_position_error(self, voevent):
            return float(voevent.WhereWhen.ObsDataLocation.ObservationLocation.AstroCoords.Position2D.Error2Radius.text)

        def get_configuration(self, voevent):
            return "None"

        def get_ligo_attributes(self, voevent):
            return {}

        def get_contour(self, l, b, error, url):
            pass

        def get_url(self, voevent):
            return "none"